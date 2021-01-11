pub use mysql::Pool;

#[macro_export]
macro_rules! get_path {
    ($path:expr) => {
        format!("/var/bazy/streamingly/{}", $path)
    }
}

#[macro_export]
macro_rules! get_db_conn {
    ($var:ident, $req:ident) => {
        let pool = $req.app_data::<Pool>().unwrap();
        let mut $var = pool.get_conn().unwrap();
    }
}

#[macro_export]
macro_rules! get_path_variable {
    ($name:expr, $var:ident, $type:ident, $httprequest:ident) => {
        let $var = $httprequest
            .match_info()
            .query($name)
            .parse::<$type>();
        if $var.is_err() {
            return HttpResponse::BadRequest().finish();
        }
        let $var = $var.unwrap();
    };
    ($name:expr, $var:ident, $httprequest:ident) => {
        let $var = $httprequest
            .match_info()
            .get($name);
    };
}
