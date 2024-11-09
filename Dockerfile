FROM node:lts-alpine AS base

# Stage 1: Install dependencies
FROM base AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN corepack enable pnpm && pnpm install --frozen-lockfile

# Stage 2: Build the application
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN corepack enable pnpm && pnpm run build

# Stage 3: Production image
FROM ghcr.io/nginxinc/nginx-unprivileged:1.27.2 AS production
WORKDIR /app
COPY --chown=nginx:nginx --from=builder /app/out /app
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
