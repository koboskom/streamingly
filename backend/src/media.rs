use actix_web::{web, HttpRequest, HttpResponse, Responder};
use actix_web::web::Bytes;
use mysql::prelude::Queryable;
use std::fs::File;
use std::io::prelude::*;
use crate::common::*;

pub fn init(cfg: &mut web::ServiceConfig) {
    cfg.route("/media/{id}", web::get().to(media));
}

async fn media(req: HttpRequest) -> impl Responder {
    get_path_variable!("id", id, i32, req);
    get_db_conn!(conn, req);

    let stmt = conn.prep("UPDATE rating as r INNER JOIN songs as s ON r.song_id = s.id SET r.count = r.count + 1 WHERE s.song_media = ?;").unwrap();
    let _ = conn.exec_drop(stmt, (id,));
    let stmt = conn.prep("SELECT path FROM media WHERE id = ?;").unwrap();
    let path: Option<String> = conn.exec_first(stmt, (id,)).unwrap();
    if let None = path {
        return HttpResponse::NotFound().finish();
    }
    let path = path.unwrap();

    let file = File::open("/var/bazy/streamingly/media/".to_owned()+&path);
    if let Err(e) = file {
        eprintln!("File open error: {:?}", e);
        return HttpResponse::NotFound().finish();
    }

    let mut buffer = Vec::new();
    let result = file.unwrap().read_to_end(&mut buffer);
    if let Err(e) = result {
        eprintln!("File read error: {:?}", e);
        return HttpResponse::InternalServerError().finish();
    }

    HttpResponse::Ok().body(Bytes::from(buffer))
}