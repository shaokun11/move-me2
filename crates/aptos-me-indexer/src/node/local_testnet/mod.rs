// Copyright © Aptos Foundation
// SPDX-License-Identifier: Apache-2.0

mod docker;
mod faucet;
mod health_checker;
mod indexer_api;
mod logging;
mod node;
mod postgres;
mod processors;
mod ready_server;
mod traits;
mod utils;

use self::{
    faucet::FaucetArgs,
    health_checker::HealthChecker,
    indexer_api::IndexerApiArgs,
    logging::ThreadNameMakeWriter,
    node::NodeArgs,
    postgres::PostgresArgs,
    processors::ProcessorArgs,
    ready_server::ReadyServerArgs,
    traits::{PostHealthyStep, ServiceManager},
};
use crate::{
    common::{
        types::{CliCommand, CliError, CliTypedResult, ConfigSearchMode, PromptOptions},
        utils::prompt_yes_with_override,
    },
    config::GlobalConfig,
    node::local_testnet::{
        faucet::FaucetManager, indexer_api::IndexerApiManager, node::NodeManager,
        processors::ProcessorManager, ready_server::ReadyServerManager, traits::ShutdownStep,
    },
};
use anyhow::{Context, Result};
use aptos_indexer_grpc_server_framework::setup_logging;
use async_trait::async_trait;
use clap::Parser;
use reqwest::Url;
use std::{
    collections::HashSet,
    fs::{create_dir_all, remove_dir_all},
    net::Ipv4Addr,
    path::{Path, PathBuf},
    pin::Pin,
};
use tokio::task::JoinSet;
use tracing::{info, warn};
use tracing_subscriber::fmt::MakeWriter;

const TESTNET_FOLDER: &str = "testnet";

/// Run a local testnet
///
/// This local testnet will run it's own genesis and run as a single node network
/// locally. A faucet and grpc transaction stream will run alongside the node unless
/// you specify otherwise with --no-faucet and --no-txn-stream respectively.
#[derive(Parser)]
pub struct RunLocalTestnet {
    /// The directory to save all files for the node
    ///
    /// Defaults to .aptos/testnet
    #[clap(long, value_parser)]
    test_dir: Option<PathBuf>,

    /// Clean the state and start with a new chain at genesis
    ///
    /// This will wipe the aptosdb in `--test-dir` to remove any incompatible changes, and start
    /// the chain fresh. Note, that you will need to publish the module again and distribute funds
    /// from the faucet accordingly.
    #[clap(long)]
    force_restart: bool,

    #[clap(flatten)]
    node_args: NodeArgs,

    #[clap(flatten)]
    faucet_args: FaucetArgs,

    #[clap(flatten)]
    postgres_args: PostgresArgs,

    #[clap(flatten)]
    processor_args: ProcessorArgs,

    #[clap(flatten)]
    indexer_api_args: IndexerApiArgs,

    #[clap(flatten)]
    ready_server_args: ReadyServerArgs,

    #[clap(flatten)]
    prompt_options: PromptOptions,

    /// By default all services running on the host system will be bound to 127.0.0.1,
    /// unless you're running the CLI inside a container, in which case it will run
    /// them on 0.0.0.0. You can use this flag to override this behavior in both cases.
    #[clap(long, hide = true)]
    bind_to: Option<Ipv4Addr>,

    /// By default, tracing output goes to files. With this set, it goes to stdout.
    #[clap(long, hide = true)]
    log_to_stdout: bool,
}

#[async_trait]
impl CliCommand<()> for RunLocalTestnet {
    fn command_name(&self) -> &'static str {
        "RunLocalTestnet"
    }

    fn jsonify_error_output(&self) -> bool {
        false
    }

    async fn execute(mut self) -> CliTypedResult<()> {
        if self.log_to_stdout {
            setup_logging(None);
        }

        let mut managers: Vec<Box<dyn ServiceManager>> = Vec::new();
        let url: Url =
            reqwest::Url::parse("http://127.0.0.1:50051").context("Failed to parse url")?;
        if self.indexer_api_args.with_indexer_api {
            let processor_managers = ProcessorManager::many_new(
                &self,
                url,
                self.postgres_args.get_connection_string(None, true),
            )
            .context("Failed to build processor service managers")?;

            let mut processor_managers = processor_managers
                .into_iter()
                .map(|m| Box::new(m) as Box<dyn ServiceManager>)
                .collect();
            managers.append(&mut processor_managers);
        }

        // Collect steps to run on shutdown. We run these in reverse. This is somewhat
        // arbitrary, each shutdown step should work no matter the order it is run in.
        let shutdown_steps: Vec<Box<dyn ShutdownStep>> = managers
            .iter()
            .flat_map(|m| m.get_shutdown_steps())
            .rev()
            .collect();

        // Run any pre-run steps.
        for manager in &managers {
            manager.pre_run().await.with_context(|| {
                format!("Failed to apply pre run steps for {}", manager.get_name())
            })?;
        }
        let mut join_set = JoinSet::new();
        // Start each of the services.
        for manager in managers.into_iter() {
            join_set.spawn(manager.run());
        }

        // Wait for all the services to start up. While doing so we also wait for any
        // of the services to end. This is not meant to ever happen (except for ctrl-c,
        // which we don't catch yet, so the process will just abort). So if it does
        // happen, it means one of the services failed to start up, in which case we
        // stop waiting for the rest of the services and error out.
        tokio::select! {
            res = join_set.join_next() => {
                eprintln!("\nOne of the services failed to start up, running shutdown steps...");
                run_shutdown_steps(shutdown_steps).await?;
                eprintln!("Ran shutdown steps");
                return Err(CliError::UnexpectedError("One of the services failed to start up".to_string()));
            }
        }
    }
}

async fn run_shutdown_steps(shutdown_steps: Vec<Box<dyn ShutdownStep>>) -> Result<()> {
    for shutdown_step in shutdown_steps {
        shutdown_step
            .run()
            .await
            .context("Failed to run shutdown step")?;
    }
    Ok(())
}
