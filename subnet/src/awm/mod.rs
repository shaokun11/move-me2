use std::io;
use serde_json::{json, Value};
use reqwest::{Client, header};
use serde::{Deserialize, Serialize};

pub struct AwmClient {
    c: Client,
    url: String,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct Message {
    pub(crate) from: String,
    pub(crate) to: String,
    pub(crate) nonce: u64,
    pub(crate) payload: Vec<u8>,
}

#[derive(Serialize, Deserialize, Clone)]
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
            "params":[json!({"data":hash})]
        });
        let response = self.c.post(self.url.as_str())
            .header(header::CONTENT_TYPE, "application/json")
            .header(header::ACCEPT, "application/json")
            .json(&request_body)
            .send().await.unwrap();
        let json_data = response.json::<Value>().await.unwrap();
        let data = serde_json::from_str::<SignedMessage>(&json_data["data"].to_string()).unwrap();
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
            .send().await.unwrap();
        let json_data = response.json::<Value>().await.unwrap();
        let key = json_data["result"]["nodePOP"]["publicKey"].as_str().unwrap();
        return Ok(key.to_string());
    }
}