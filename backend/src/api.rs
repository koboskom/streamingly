use crate::model::{Song, Artist, Genre, Album};
use actix_web::{web, HttpRequest, HttpResponse, Responder};
use mysql::prelude::Queryable;
use std::collections::{HashMap, HashSet};
use crate::common::*;

macro_rules! get_limit_and_offset {
    ($query:ident, $limit:ident, $offset:ident) => {
        let $limit = match $query.get("limit") {
            None => Ok(5),
            Some(ref x) => x.parse::<i32>(),
        };
        if let Err(_) = $limit {
            return HttpResponse::BadRequest().finish();
        }
        let $limit = $limit.unwrap();
        let $offset = match $query.get("offset") {
            None => Ok(0),
            Some(ref x) => x.parse::<i32>(),
        };
        if let Err(_) = $offset {
            return HttpResponse::BadRequest().finish();
        }
        let $offset = $offset.unwrap();
    }
}

fn parse_songs(output: Vec<(i32, i32, String, String, i32, i32, String, i32, String)>) -> Vec<Song> {
    let mut songs: HashMap<i32, Song> = HashMap::new();
    for row in output {
        let song = songs.entry(row.0).or_insert(
                Song {
                    id: row.0,
                    album_id: row.1,
                    title: row.2,
                    filetype: row.3,
                    media: row.4,
                    genres: HashSet::new(),
                    artists: HashSet::new(),
                });
        song.genres.insert((row.5, row.6));
        song.artists.insert((row.7, row.8));
    }
    songs.into_iter().map(|(_, song)| song).collect()
}

async fn albums(req: HttpRequest, query: web::Query<HashMap<String, String>>) -> impl Responder {
    get_path_variable!("id", id, req);
    get_limit_and_offset!(query, limit, offset);
    get_db_conn!(conn, req);

    let output: Vec<(i32, String, i32)> = if let Some(id) = id {
        let stmt = conn.prep("SELECT id, album_id, title, filetype, media, ge, image_media FROM albums WHERE id = ? LIMIT ? OFFSET ?;").unwrap();
        conn.exec(stmt, (id, limit, offset)).unwrap()
    } else {
        let stmt = conn.prep("SELECT id, name, image_media FROM albums LIMIT ? OFFSET ?;").unwrap();
        conn.exec(stmt, (limit, offset)).unwrap()
    };
    HttpResponse::Ok().json(output.into_iter().map(|r| r.into()).collect::<Vec<Album>>())
}

async fn songs(req: HttpRequest, query: web::Query<HashMap<String, String>>) -> impl Responder {
    get_path_variable!("id", id, req);
    get_limit_and_offset!(query, limit, offset);
    get_db_conn!(conn, req);

    let output = if let Some(id) = id {
        let stmt = conn.prep("
            SELECT
                s.id,
                s.album_id,
                s.title,
                s.filetype,
                s.song_media,
                g.id,
                g.name,
                a.id,
                a.name
            FROM
                songs as s,
                song_genre as sg,
                genres as g,
                song_artist as sa,
                artists as a
            WHERE
                s.id = ? and
                sg.song_id = s.id and sg.genre_id = g.id and
                sa.song_id = s.id and sa.artist_id = a.id;").unwrap();
        conn.exec(stmt, (id,)).unwrap()
    } else {
        let stmt = conn.prep("WITH songs_ids as (
            SELECT
                id,
                ROW_NUMBER() OVER(ORDER BY id) as num
            FROM
                songs
            )
            SELECT
                s.id,
                s.album_id,
                s.title,
                s.filetype,
                s.song_media,
                g.id,
                g.name,
                a.id,
                a.name
            FROM
                songs as s,
                song_genre as sg,
                genres as g,
                song_artist as sa,
                artists as a,
                songs_ids as si
            WHERE
                si.id = s.id and si.num > ? and si.num <= ? and
                sg.song_id = s.id and sg.genre_id = g.id and
                sa.song_id = s.id and sa.artist_id = a.id;").unwrap();
        conn.exec(stmt, (offset, limit+offset)).unwrap()
    };
    let songs = parse_songs(output);
    HttpResponse::Ok().json(songs)
}

async fn artists(req: HttpRequest, query: web::Query<HashMap<String, String>>) -> impl Responder {
    get_path_variable!("id", id, req);
    get_limit_and_offset!(query, limit, offset);
    get_db_conn!(conn, req);

    let output: Vec<(i32, String, i32)> = if let Some(id) = id {
        let stmt = conn.prep("SELECT id, name, image_media FROM artists WHERE id = ?;").unwrap();
        conn.exec(stmt, (id,)).unwrap()
    } else {
        let stmt = conn.prep("SELECT id, name, image_media FROM artists LIMIT ? OFFSET ?;").unwrap();
        conn.exec(stmt, (limit, offset)).unwrap()
    };
    HttpResponse::Ok().json(output.into_iter().map(|r| r.into()).collect::<Vec<Artist>>())
}

async fn genres(req: HttpRequest, query: web::Query<HashMap<String, String>>) -> impl Responder {
    get_path_variable!("id", id, req);
    get_limit_and_offset!(query, limit, offset);
    get_db_conn!(conn, req);

    let output: Vec<(i32, String, i32)> = if let Some(id) = id {
        let stmt = conn.prep("SELECT id, name, image_media FROM genres WHERE id = ?;").unwrap();
        conn.exec(stmt, (id,)).unwrap()
    } else {
        let stmt = conn.prep("SELECT id, name, image_media FROM genres LIMIT ? OFFSET ?;").unwrap();
        conn.exec(stmt, (limit, offset)).unwrap()
    };
    HttpResponse::Ok().json(output.into_iter().map(|r| r.into()).collect::<Vec<Genre>>())
}

async fn albums_songs(req: HttpRequest, query: web::Query<HashMap<String, String>>) -> impl Responder {
    get_path_variable!("id", album_id, i32, req);
    get_limit_and_offset!(query, limit, offset);
    get_db_conn!(conn, req);

    let stmt = conn.prep("WITH songs_nums as (
        SELECT
            id,
            ROW_NUMBER() OVER(ORDER BY id) as num
        FROM
            songs
        WHERE
            album_id = ?
        )
        SELECT
            s.id,
            s.album_id,
            s.title,
            s.filetype,
            s.song_media,
            g.id,
            g.name,
            a.id,
            a.name
        FROM
            songs as s,
            song_genre as sg,
            genres as g,
            song_artist as sa,
            artists as a,
            songs_nums as sn
        WHERE
            sn.id = s.id and sn.num > ? and sn.num <= ? and
            sg.song_id = s.id and sg.genre_id = g.id and
            sa.song_id = s.id and sa.artist_id = a.id;").unwrap();
    let songs = parse_songs(conn.exec(stmt, (album_id, offset, limit+offset)).unwrap());
    HttpResponse::Ok().json(songs)
}

async fn artists_songs(req: HttpRequest, query: web::Query<HashMap<String, String>>) -> impl Responder {
    get_path_variable!("id", artist_id, i32, req);
    get_limit_and_offset!(query, limit, offset);
    get_db_conn!(conn, req);

    let stmt = conn.prep("WITH songs_ids as (
        SELECT
            s.id,
            ROW_NUMBER() OVER(ORDER BY id) as num
        FROM
            songs as s,
            song_artist as sa
        WHERE
            sa.song_id = s.id and sa.artist_id = ?
        )
        SELECT
            s.id,
            s.album_id,
            s.title,
            s.filetype,
            s.song_media,
            g.id,
            g.name,
            a.id,
            a.name
        FROM
            songs as s,
            song_genre as sg,
            genres as g,
            song_artist as sa,
            artists as a,
            songs_ids as si
        WHERE
            si.id = s.id and si.num > ? and si.num <= ? and
            sg.song_id = s.id and sg.genre_id = g.id and
            sa.song_id = s.id and sa.artist_id = a.id;").unwrap();
    let songs = parse_songs(conn.exec(stmt, (artist_id, offset, limit+offset)).unwrap());
    HttpResponse::Ok().json(songs)
}

async fn genres_songs(req: HttpRequest, query: web::Query<HashMap<String, String>>) -> impl Responder {
    get_path_variable!("id", genre_id, i32, req);
    get_limit_and_offset!(query, limit, offset);
    get_db_conn!(conn, req);

    let stmt = conn.prep("WITH songs_ids as (
        SELECT
            s.id,
            ROW_NUMBER() OVER(ORDER BY id) as num
        FROM
            songs as s,
            song_genre as sg
        WHERE
            sg.song_id = s.id and sg.genre_id = ?
        )
        SELECT
            s.id,
            s.album_id,
            s.title,
            s.filetype,
            s.song_media,
            g.id,
            g.name,
            a.id,
            a.name
        FROM
            songs as s,
            song_genre as sg,
            genres as g,
            song_artist as sa,
            artists as a,
            songs_ids as si
        WHERE
            si.id = s.id and si.num > ? and si.num <= ? and
            sg.song_id = s.id and sg.genre_id = g.id and
            sa.song_id = s.id and sa.artist_id = a.id;").unwrap();
    let songs = parse_songs(conn.exec(stmt, (genre_id, offset, limit+offset)).unwrap());
    HttpResponse::Ok().json(songs)
}

pub fn init(cfg: &mut web::ServiceConfig) {
    cfg.route("/api/artists", web::get().to(artists));
    cfg.route("/api/artists/{id}", web::get().to(artists));
    cfg.route("/api/artists/{id}/songs", web::get().to(artists_songs));

    cfg.route("/api/albums", web::get().to(albums));
    cfg.route("/api/albums/{id}", web::get().to(albums));
    cfg.route("/api/albums/{id}/songs", web::get().to(albums_songs));

    cfg.route("/api/genres", web::get().to(genres));
    cfg.route("/api/genres/{id}", web::get().to(genres));
    cfg.route("/api/genres/{id}/songs", web::get().to(genres_songs));

    cfg.route("/api/songs", web::get().to(songs));
    cfg.route("/api/songs/{id}", web::get().to(songs));
}