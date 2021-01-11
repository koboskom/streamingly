#[macro_use]
mod common;
mod media;
mod api;
mod model;
mod website;

use actix_web::{App, HttpServer, middleware::{NormalizePath, normalize::TrailingSlash}};
use actix_cors::Cors;
use mysql::Pool;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let url = "mysql://<username>:<password>@127.0.0.1:3306/streamingly";
    let pool = Pool::new(url).unwrap();

    HttpServer::new(move || {
        let cors = Cors::default()
            .allow_any_origin();

        App::new()
            .wrap(cors)
            .wrap(NormalizePath::new(TrailingSlash::Trim))
            .app_data(pool.clone())
            .configure(api::init)
            .configure(website::init)
            .configure(media::init)
    })
    .bind("0.0.0.0:3000")?
    .run()
    .await
}
