use anyhow::Result;
use axum::extract::{Query, State};
use axum::response::IntoResponse;
use axum::{
    http::StatusCode,
    response::Response,
    routing::{get, post},
    Json, Router,
};
use leveldb::db::Database;
use leveldb::options::{Options, ReadOptions, WriteOptions};
use serde::Deserialize;
use std::path::Path as FilePath;
use std::sync::Arc;
#[derive(Deserialize)]
struct KeyValue {
    key: String,
    value: String,
}
#[derive(Debug, Deserialize)]
struct QueryParams {
    key: String,
}

#[tokio::main]
async fn main() -> Result<()> {
    let path = FilePath::new("../db/tx");
    let options = Options::new();
    // options.create_if_missing = true;
    let database = Database::open(&path, &options)?;
    let app_state = Arc::new(database);
    let app = Router::new()
        .route("/", post(put_handler))
        .route("/", get(get_handler))
        .with_state(app_state);
    let listener = tokio::net::TcpListener::bind(format!("127.0.0.1:{}", 8898)).await?;
    axum::serve(listener, app).await?;
    Ok(())
}

async fn put_handler(
    State(db): State<Arc<Database>>,
    Json(payload): Json<KeyValue>,
) -> Result<&'static str, AppError> {
    let write_ops = WriteOptions::new();
    db.put(
        &write_ops,
        &payload.key.as_bytes(),
        &payload.value.as_bytes(),
    )?;
    Ok("ok")
}

async fn get_handler(
    State(db): State<Arc<Database>>,
    Query(query): Query<QueryParams>,
) -> Result<String, AppError> {
    let read_ops = ReadOptions::new();
    let value = db.get(&read_ops, &query.key.as_bytes())?;
    match value {
        Some(value) => {
            let value = std::str::from_utf8(&value).unwrap().to_string();
            Ok(value)
        }
        None => Ok("".to_string()),
    }
}

// Make our own error that wraps `anyhow::Error`.
struct AppError(anyhow::Error);

impl std::fmt::Display for AppError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

// Tell axum how to convert `AppError` into a response.
impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        (StatusCode::OK, "").into_response()
    }
}

// This enables using `?` on functions that return `Result<_, anyhow::Error>` to turn them into
// `Result<_, AppError>`. That way you don't need to do that manually.
impl<E> From<E> for AppError
where
    E: Into<anyhow::Error>,
{
    fn from(err: E) -> Self {
        Self(err.into())
    }
}
