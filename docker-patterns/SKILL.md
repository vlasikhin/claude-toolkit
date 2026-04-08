---
name: docker-patterns
description: Docker and Docker Compose patterns for development and production. Use when writing Dockerfiles, setting up Docker Compose for local dev, or containerizing a Rails app. Use when user says "Docker", "Dockerfile", "docker-compose", "containerize", or "dev environment setup".
license: MIT
metadata:
  author: vlasikhin
  version: 1.0.0
---

# Docker Patterns

Conventions for Dockerfiles and Compose for Rails development and production.

## Core Principles

- One process per container (Rails, Sidekiq, PostgreSQL — separate containers)
- Separate dev and production configs
- Pin image versions — never use `:latest`
- Non-root user in production images

## Development Compose

Typical Rails dev stack:

```yaml
services:
  web:
    build:
      context: .
      target: development
    volumes:
      - .:/app
      - bundle_cache:/usr/local/bundle
    ports:
      - "3000:3000"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    environment:
      DATABASE_URL: postgres://postgres:postgres@postgres:5432/app_dev
      REDIS_URL: redis://redis:6379/0

  sidekiq:
    build:
      context: .
      target: development
    command: bundle exec sidekiq
    volumes:
      - .:/app
      - bundle_cache:/usr/local/bundle
    depends_on:
      - postgres
      - redis
    environment:
      DATABASE_URL: postgres://postgres:postgres@postgres:5432/app_dev
      REDIS_URL: redis://redis:6379/0

  postgres:
    image: postgres:16-alpine
    volumes:
      - pg_data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: postgres
    healthcheck:
      test: pg_isready -U postgres
      interval: 5s
      retries: 3

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    healthcheck:
      test: redis-cli ping
      interval: 5s
      retries: 3

volumes:
  pg_data:
  redis_data:
  bundle_cache:
```

## Multi-Stage Dockerfile

```dockerfile
# --- Base ---
FROM ruby:3.3-slim AS base
WORKDIR /app
RUN apt-get update -qq && apt-get install -y libpq-dev

# --- Development ---
FROM base AS development
RUN apt-get install -y build-essential git
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# --- Production build ---
FROM base AS build
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test
COPY . .
RUN bundle exec rails assets:precompile SECRET_KEY_BASE_DUMMY=1

# --- Production ---
FROM base AS production
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app
USER nobody
EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

Target a specific stage: `docker compose build --build-arg target=development`

## Volumes

| Type | Purpose | Example |
|---|---|---|
| Bind mount | Source code (live reload) | `.:/app` |
| Named volume | Persistent data (DB, Redis) | `pg_data:/var/lib/postgresql/data` |
| Named volume | Dependency cache (gems) | `bundle_cache:/usr/local/bundle` |

Never use bind mounts for database data. Never use named volumes for source code in dev.

## Health Checks

Always add health checks to service dependencies. Without them, `depends_on` only waits for the container to start, not for the service inside to be ready.

```yaml
healthcheck:
  test: pg_isready -U postgres
  interval: 5s
  timeout: 3s
  retries: 3
  start_period: 10s
```

## .dockerignore

```
.git
tmp
log
node_modules
spec
.rspec
.rubocop.yml
coverage
.env*
```

Keep images small. Exclude everything not needed at runtime.

## Security

- Run production containers as `nobody` or a dedicated user
- Drop Linux capabilities: `cap_drop: [ALL]`
- Never hardcode secrets in Dockerfile — use environment variables
- Scan images for vulnerabilities: `docker scout cves`
- Pin base image digests for reproducible builds in CI

## Common Pitfalls

- Forgetting `bundle_cache` volume — gems re-install on every build
- Missing `depends_on` with health checks — app starts before DB is ready
- Using `docker-compose.yml` for production (use orchestration: Kamal, K8s, ECS)
- Storing state in containers without volumes — data lost on restart
- Running everything as root in production containers
