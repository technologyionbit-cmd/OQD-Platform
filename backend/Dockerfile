# Multi-stage build for the NestJS app itself.
# Not wired into docker-compose.yml in Phase 1A (which only provisions
# PostgreSQL/Redis) — this exists so the app can be containerized when a
# later phase adds real deployment infrastructure.

FROM node:24-alpine AS build
WORKDIR /app

COPY package*.json ./
COPY prisma ./prisma
RUN npm ci

COPY tsconfig*.json nest-cli.json ./
COPY src ./src
RUN npx prisma generate
RUN npm run build

FROM node:24-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
COPY prisma ./prisma
RUN npm ci --omit=dev
RUN npx prisma generate

COPY --from=build /app/dist ./dist

EXPOSE 3000
CMD ["node", "dist/main.js"]
