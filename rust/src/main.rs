mod model;
mod publish;
mod search;

use actix_web::{head, App, HttpResponse, HttpServer};
use sqlx::postgres::PgPoolOptions;

fn server_address() -> String {
    std::env::var("ADDRESS").unwrap_or_else(|_| String::from("0.0.0.0:3000"))
}

fn database_address() -> String {
    std::env::var("DATABASE_URL")
        .unwrap_or_else(|_| String::from("postgres://eco:dummy@localhost/eco"))
}

#[head("/")]
async fn status() -> HttpResponse {
    HttpResponse::NoContent().finish()
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init();

    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&database_address())
        .await
        .expect("couldn't connect database");

    HttpServer::new(move || {
        App::new()
            .data(pool.clone())
            .service(status)
            .service(publish::handle)
            .service(search::handle)
    })
    .bind(server_address())?
    .run()
    .await
}
