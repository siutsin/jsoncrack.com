# Builder
FROM node:20-alpine AS builder
# Reference :: https://pnpm.io/docker
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
WORKDIR /src

# Cache dependencies first
COPY package.json pnpm-lock.yaml ./
RUN pnpm install

# Copy other files and build
COPY . /src/
RUN pnpm build

# App
FROM nginxinc/nginx-unprivileged:1.27.2
COPY --chown=nginx:nginx --from=builder /src/out /app
COPY default.conf /etc/nginx/conf.d/default.conf
