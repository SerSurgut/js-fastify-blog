setup: install db-migrate

install:
	npm install

db-migrate:
	npm run migrate

build:
	npm run build

prepare-env:
	cp -n .env.example .env

start:
	NODE_ENV=production npm run start

dev:
	npx concurrently "make start-frontend" "make start-backend"

start-backend:
	npm start -- --watch --verbose-watch --ignore-watch='node_modules .git .sqlite'

start-frontend:
	npx webpack --watch --progress

lint:
	npx eslint .

lint-fix:
	npx eslint --fix .

test:
	NODE_ENV=test npm test -s

# --- Docker Compose ---

compose-build:
	docker compose build

compose-dev:
	docker compose up dev

compose-prod:
	docker compose up web

compose-test:
	docker compose run --rm tests

compose-lint:
	docker compose run --rm tests npx eslint .

compose-bash:
	docker compose run --rm dev bash

compose-down:
	docker compose down -v

compose-logs:
	docker compose logs -f
