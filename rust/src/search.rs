use crate::model::LogEntry;
use actix_web::{get, web, HttpResponse, Responder};
use sqlx::PgPool;

#[derive(Debug, serde::Deserialize)]
pub struct QueryParams {
    #[serde(default = "QueryParams::default_count")]
    count: usize,
    #[serde(default = "QueryParams::default_offset")]
    offset: usize,
}

impl QueryParams {
    fn default_count() -> usize {
        100
    }

    fn default_offset() -> usize {
        0
    }
}

#[get("/search")]
pub async fn handle(db: web::Data<PgPool>, params: web::Query<QueryParams>) -> impl Responder {
    LogEntry::fetch(db.get_ref(), params.count, params.offset)
        .await
        .map(|list| HttpResponse::Ok().json(list))
        .map_err(|err| HttpResponse::InternalServerError().json(err.to_string()))
}
