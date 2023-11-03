use std::io;
use std::time::Duration;
use serde_json::{json, Value};
use reqwest::{Client, header};
use serde::{Deserialize, Serialize};

pub struct AwmClient {
    c: Client,
    url: String,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct Message {
    pub(crate) from: String,
    pub(crate) to: String,
    pub(crate) payload: String,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct SignedMessage {
    pub message: Message,
    pub(crate) signature: String,
}

impl AwmClient {
    pub fn get_rpc_url(uri: &str, chain_id: &str) -> String {
        format!("{}/ext/{}/{}/rpc", uri, "bc", chain_id)
    }
    pub fn get_node_url(uri: &str) -> String {
        format!("{}/ext/info", uri)
    }

    pub fn new(url: &str) -> Self {
        let client = Client::new();
        AwmClient { c: client, url: url.to_string() }
    }
    pub async fn get_message(&self, hash: &str) -> io::Result<SignedMessage> {
        let request_body = json!({
            "jsonrpc": "2.0",
            "method": "getMessage",
            "id": 1,
            "params":[json!({"tx_hash":hash})]
        });
        let response = self.c.post(self.url.as_str())
            .header(header::CONTENT_TYPE, "application/json")
            .header(header::ACCEPT, "application/json")
            .json(&request_body)
            .timeout(Duration::from_secs(5))
            .send().await.unwrap();
        let json_data = response.json::<Value>().await.unwrap();
        let data = serde_json::from_str::<SignedMessage>(&json_data["result"]["data"].as_str().unwrap()).unwrap();
        Ok(data)
    }
    pub async fn get_node(&self) -> io::Result<String> {
        let request_body = json!({
            "jsonrpc": "2.0",
            "method": "info.getNodeID",
            "id": 1,
            "params":[]
        });
        let response = self.c.post(self.url.as_str())
            .header(header::CONTENT_TYPE, "application/json")
            .header(header::ACCEPT, "application/json")
            .json(&request_body)
            .timeout(Duration::from_secs(5))
            .send().await.unwrap();
        let json_data = response.json::<Value>().await.unwrap();
        let key = json_data["result"]["nodePOP"]["publicKey"].to_string();
        return Ok(key);
    }
}