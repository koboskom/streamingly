use mysql::Pool;

static connection: Option<Pool> = None;

pub fn get() {
    if let None = connection {

    }
}
