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
	npm run build --prefix frontend
	cd frontend && npx gulp
	cp frontend/build/index.html ${OUT_DIR}/static/
	cp frontend/build/manifest.json ${OUT_DIR}/static/

run: all
	cd ${OUT_DIR}
	./streamingly
