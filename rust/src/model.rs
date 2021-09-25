use actix_web::{Error, HttpRequest, HttpResponse, Responder};
use anyhow::Result;
use chrono::serde::ts_seconds::{deserialize as from_ts, serialize as to_ts};
use chrono::{DateTime, Utc};
use futures::future::{ready, Ready};
use sqlx::postgres::{PgPool, PgRow};
use sqlx::Row;

#[derive(Debug, serde::Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LogCreation {
    #[serde(deserialize_with = "from_ts")]
    created_at: DateTime<Utc>,
    level: String,
    #[serde(flatten)]
    payload: serde_json::Value,
}

impl LogCreation {
    pub async fn create(db: &PgPool, values: Vec<LogCreation>) -> Result<()> {
        let mut tx = db.begin().await?;
        let (created_at, level, payload) =
            values
                .iter()
                .fold((Vec::new(), Vec::new(), Vec::new()), |mut res, entry| {
                    res.0.push(entry.created_at.clone());
                    res.1.push(entry.level.clone());
                    res.2.push(entry.payload.clone());
                    res
                });
        sqlx::query(
            r#"
        INSERT INTO mylogs (created_at, level, payload)
        SELECT * FROM UNNEST($1, $2, $3)
        "#,
        )
        .bind(&created_at)
        .bind(&level)
        .bind(&payload)
        .execute(&mut tx)
        .await?;
        tx.commit().await?;
        Ok(())
    }
}

#[derive(Debug, serde::Serialize)]
#[serde(rename_all = "camelCase")]
pub struct LogEntry {
    id: uuid::Uuid,
    #[serde(serialize_with = "to_ts")]
    created_at: DateTime<Utc>,
    level: String,
    #[serde(flatten)]
    payload: serde_json::Value,
}

impl Responder for LogEntry {
    type Error = Error;
    type Future = Ready<Result<HttpResponse, Error>>;

    fn respond_to(self, _req: &HttpRequest) -> Self::Future {
        ready(Ok(HttpResponse::Ok().json(self)))
    }
}

impl LogEntry {
    pub async fn fetch(db: &PgPool, count: usize, offset: usize) -> Result<Vec<LogEntry>> {
        let list = sqlx::query(
            r#"
        SELECT id, created_at, level, payload
        FROM mylogs
        ORDER BY created_at
        LIMIT $1
        OFFSET $2
        "#,
        )
        .bind(count as u32)
        .bind(offset as u32)
        .map(|row: PgRow| Self {
            id: row.get(0),
            created_at: row.get(1),
            level: row.get(2),
            payload: row.get(3),
        })
        .fetch_all(&*db)
        .await?;
        Ok(list)
    }
}
