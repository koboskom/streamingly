use actix_web::{web, HttpRequest, Result};
use actix_files::{Files, NamedFile};

pub fn init(cfg: &mut web::ServiceConfig) {
    cfg.route("/", web::get().to(index));
    cfg.route("/artists{rest:.*}", web::get().to(index));
    cfg.route("/genre{rest:.*}", web::get().to(index));
    cfg.route("/favicon.ico", web::get().to(file));
    cfg.route("/manifest.json", web::get().to(file));
    cfg.service(Files::new("/static", "/var/bazy/streamingly/static"));
}

async fn file(req: HttpRequest) -> Result<NamedFile> {
    let path = format!("static{}", req.uri());
    eprintln!("Uri: {}", path);
    Ok(NamedFile::open(get_path!(path))?)
}

async fn index(_req: HttpRequest) -> Result<NamedFile> {
    Ok(NamedFile::open(get_path!("static/index.html"))?)
}
