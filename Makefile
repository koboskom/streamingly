# BUILD could be release or debug
BUILD=release
OUT_DIR='out'

all: backend frontend

env:
	rm -rf ${OUT_DIR}/ 2> /dev/null
	mkdir -p ${OUT_DIR}/static
	mkdir -p ${OUT_DIR}/media

backend: env
	cargo build --target-dir . --manifest-path backend/Cargo.toml --${BUILD}
	mv ${BUILD}/streamingly ${OUT_DIR}/

frontend: env
	cp frontend/build/index.html out/static/
	cp frontend/build/manifest.json out/static/

run: all
	cd ${OUT_DIR}
	./streamingly
