# syntax=docker/dockerfile:1

# ---------- Stage 1: builder ----------
# Содержит все зависимости (включая dev) и собранные webpack-ассеты.
# Используется как образ для dev и tests сервисов docker-compose.
FROM node:20 AS builder

WORKDIR /app

# Сначала зависимости — слой кэшируется при неизменённом package*.json
COPY package*.json .npmrc ./
RUN npm ci

# Копируем исходники и собираем фронтенд
COPY . .
RUN npm run build

EXPOSE 8080
CMD ["npm", "run", "dev"]

# ---------- Stage 2: prod-deps ----------
# Чистая инсталляция только production-зависимостей.
# В полном node:20 — потому что нативным модулям (pg, sqlite3) нужны python/make/g++.
FROM node:20 AS prod-deps

WORKDIR /app

COPY package*.json .npmrc ./
RUN npm ci --omit=dev


# ---------- Stage 3: production ----------
# Финальный лёгкий образ для запуска приложения.
FROM node:20-slim AS production

ENV NODE_ENV=production
WORKDIR /app

# Production-зависимости (уже скомпилированные)
COPY --from=prod-deps /app/node_modules ./node_modules

# Собранные фронтенд-ассеты
COPY --from=builder /app/dist ./dist

# Исходный код приложения
COPY . .

EXPOSE 8080

# prestart-хук в package.json автоматически прогонит миграции
CMD ["npm", "start"]
