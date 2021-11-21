use actix_web::{head, post, web, App, HttpResponse, HttpServer};
use chrono::serde::ts_seconds::deserialize as from_ts;
use chrono::{DateTime, Utc};
use std::collections::HashMap;

#[derive(Debug, serde::Serialize, serde::Deserialize)]
pub struct Event {
    #[serde(deserialize_with = "from_ts")]
    ts: DateTime<Utc>,
    tags: HashMap<String, String>,
    values: HashMap<String, serde_json::Value>,
}

#[post("/publish")]
pub async fn handle_publish(
    blackhole: web::Data<Blackhole>,
    payload: web::Json<Event>,
) -> HttpResponse {
    let mut payload = payload.into_inner();
    payload.tags.insert("through".into(), "rust".into());
    match blackhole.publish(payload).await {
        Ok(_) => HttpResponse::NoContent().finish(),
        Err(err) => HttpResponse::InternalServerError().json(&err),
    }
}

#[get("/")]
async fn handle_status() -> HttpResponse {
    HttpResponse::NoContent().finish()
}

fn server_address() -> String {
    std::env::var("ADDRESS").unwrap_or_else(|_| String::from("localhost:3000"))
}

#[derive(Clone)]
pub struct Blackhole {
    client: reqwest::Client,
    url: String,
}

impl Blackhole {
    pub fn from_env() -> Self {
        Self {
            client: reqwest::Client::new(),
            url: std::env::var("BLACKHOLE_URL")
                .unwrap_or_else(|_| String::from("http://localhost:3010")),
        }
    }

    pub async fn publish(&self, event: Event) -> Result<(), String> {
        self.client
            .post(&self.url)
            .json(&event)
            .send()
            .await
            .map_err(|err| err.to_string())?;
        Ok(())
    }
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let blackhole = Blackhole::from_env();

    HttpServer::new(move || {
        App::new()
            .app_data(web::Data::new(blackhole.clone()))
            .service(handle_status)
            .service(handle_publish)
    })
    .bind(server_address())?
    .run()
    .await
}
