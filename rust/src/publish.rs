use crate::model::LogCreation;
use actix_web::{post, web, HttpResponse, Responder};
use sqlx::PgPool;

#[post("/publish")]
pub async fn handle(db: web::Data<PgPool>, payload: web::Json<Vec<LogCreation>>) -> impl Responder {
    LogCreation::create(db.get_ref(), payload.0)
        .await
        .map(|_| HttpResponse::NoContent().finish())
        .map_err(|err| HttpResponse::InternalServerError().json(err.to_string()))
}
