use serde::Serialize;
use std::collections::HashSet;

#[derive(Serialize)]
pub struct Song {
    pub id: i32,
    pub album_id: i32,
    pub title: String,
    pub filetype: String,
    pub media: i32,
    pub genres: HashSet<(i32, String)>,
    pub artists: HashSet<(i32, String)>,
}

#[derive(Serialize)]
pub struct Album {
    id: i32,
    name: String,
    media: i32
}

impl From<(i32, String, i32)> for Album {
    fn from(tuple: (i32, String, i32)) -> Self {
        Album {
            id: tuple.0,
            name: tuple.1,
            media: tuple.2,
        }
    }
}

#[derive(Serialize)]
pub struct Artist {
    id: i32,
    name: String,
    media: i32
}

impl From<(i32, String, i32)> for Artist {
    fn from(tuple: (i32, String, i32)) -> Self {
        Artist {
            id: tuple.0,
            name: tuple.1,
            media: tuple.2,
        }
    }
}

#[derive(Serialize)]
pub struct Genre {
    id: i32,
    name: String,
    media: i32,
}

impl From<(i32, String, i32)> for Genre {
    fn from(tuple: (i32, String, i32)) -> Self {
        Genre {
            id: tuple.0,
            name: tuple.1,
            media: tuple.2,
        }
    }
}
