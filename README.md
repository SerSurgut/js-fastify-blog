# JS Fastify Blog

Учебный проект: блог на Fastify, упакованный в Docker Compose с PostgreSQL, тестами в CI и автоматической публикацией образа на Docker Hub.

## Требования

* Docker и Docker Compose
* (опционально) Node.js v20.x — для запуска без Docker

## Архитектура Docker Compose

Один файл `docker-compose.yml`, четыре сервиса:

| Сервис  | Назначение                                                                              |
| ------- | --------------------------------------------------------------------------------------- |
| `db`    | PostgreSQL 16 с healthcheck                                                             |
| `web`   | Финальный production-образ (multi-stage build, target `production`), слушает `:8080`    |
| `dev`   | Разработка: target `builder`, hot reload через монтирование исходников, тоже на `:8080` |
| `tests` | Прогон тестов и линтера в Postgres (используется в CI и локально)                       |

Multi-stage Dockerfile содержит три стадии: `builder` (devDependencies + webpack build) → `prod-deps` (только prod-зависимости) → `production` (на `node:20-slim`).

## Быстрый старт

```bash
# Скопировать пример переменных окружения
make prepare-env
```

### Локальная разработка

```bash
make compose-dev
# эквивалент: docker compose up dev
```

Приложение доступно на http://localhost:8080. Изменения в исходниках подхватываются автоматически.

### Запуск приложения в продакшен-режиме

```bash
make compose-prod
# эквивалент: docker compose up web
```

### Прогон тестов

```bash
make compose-test
# эквивалент: docker compose run --rm tests
```

### Запуск линтера в контейнере

```bash
make compose-lint
```

### Остановить и удалить контейнеры/тома

```bash
make compose-down
```

## Переменные окружения

Файл `.env.example`:

```dotenv
DATABASE_NAME=postgres
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
DATABASE_PORT=5432
DATABASE_HOST=db   # внутри docker compose; вне Docker — localhost
```

## CI / CD

GitHub Actions (`.github/workflows/nodejs.yml`) выполняет две джобы:

1. **test** — поднимает контейнеры из `docker-compose.yml`, прогоняет в сервисе `tests` сначала `eslint`, потом `npm test`.
2. **publish** — на push в `main` собирает финальный production-образ и публикует его на Docker Hub под тегами `latest` и `<github.sha>`.

GitHub Secrets, нужные для publish:

* `DOCKERHUB_USERNAME` — логин на hub.docker.com
* `DOCKERHUB_TOKEN` — Personal Access Token из настроек Docker Hub

## Запуск опубликованного образа

```bash
docker run --rm -p 8080:8080 \
  -e DATABASE_HOST=<host> \
  -e DATABASE_PORT=5432 \
  -e DATABASE_NAME=postgres \
  -e DATABASE_USERNAME=postgres \
  -e DATABASE_PASSWORD=postgres \
  <ваш-логин>/js-fastify-blog:latest
```

---

Repository forked from [hexlet-components/js-fastify-blog](https://github.com/hexlet-components/js-fastify-blog).
