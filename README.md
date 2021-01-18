# Streamingly

The site is currently hosted on https://g17.labagh.pl/

## Requirements
- mySQL database named streamingly

- `rustup` and `cargo`
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

- `node` and `npm`\
refer to [this](https://nodejs.org/en/download/)

- npm dependencies
```bash
cd frontend
npm install
```

## Build
To build project run make at the root directory
```bash
make
```

## Run
To start streamingly server run:
```bash
make run
```

## Advanced
To configure output directory change `OUT_DIR` in Makefile.\
Currently you can only specify database username and password in rust code\
// TODO(pixsll): Create config file to tweak backend parameters

## Demo

![](/photos/menu.png)
![](/photos/albums.png)
![](/photos/genres.png)
![](/photos/artists.png)
![](/photos/albumsins.png)
