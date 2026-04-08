---
name: deployment-patterns
description: Deployment strategies, CI/CD pipelines, and production readiness for Rails. Use when setting up deploys, choosing a deployment strategy, building CI pipelines, or preparing for production. Use when user says "deploy", "CI/CD", "production ready", "blue-green", "canary deploy", or "Kamal".
license: MIT
metadata:
  author: vlasikhin
  version: 1.0.0
---

# Deployment Patterns

Strategies for shipping Rails applications safely.

## Deployment Strategies

### Rolling

Gradually replace instances with new version. Old and new run simultaneously during rollout.
- **Pro:** Simple, minimal infrastructure
- **Con:** Must maintain backward compatibility between versions
- **Use for:** Most Rails apps, standard deploys

### Blue-Green

Two identical environments. Deploy to inactive, switch traffic atomically.
- **Pro:** Instant rollback (switch back), zero downtime
- **Con:** Doubled infrastructure cost
- **Use for:** Critical apps where rollback speed matters

### Canary

Route a small percentage of traffic (5-10%) to new version. Monitor, then expand.
- **Pro:** Catches issues before full rollout
- **Con:** More complex routing, requires good monitoring
- **Use for:** High-traffic apps, risky changes

## Rails Deploy with Kamal

Kamal (Rails default since 7.x) handles Docker-based deploys:

```
kamal setup              # first deploy
kamal deploy             # subsequent deploys
kamal rollback           # revert to previous version
kamal app logs           # check production logs
```

Kamal does rolling deploys by default with health checks between container swaps.

## CI/CD Pipeline

Standard order for Rails projects:

```yaml
# .github/workflows/ci.yml
jobs:
  lint:
    - bundle exec rubocop
  test:
    - bundle exec rspec
    services:
      postgres:
      redis:
  security:
    - bundle exec brakeman -q
    - bundle audit check
  deploy:
    needs: [lint, test, security]
    if: github.ref == 'refs/heads/main'
```

Run lint, test, and security in parallel. Deploy only after all pass.

## Docker for Production

Multi-stage build — separate build from runtime:

```dockerfile
FROM ruby:3.3-slim AS build
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test
COPY . .
RUN bundle exec rails assets:precompile

FROM ruby:3.3-slim
WORKDIR /app
COPY --from=build /app /app
USER nobody
EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

Rules:
- Pin Ruby version (no `:latest`)
- Non-root user in runtime stage
- `.dockerignore` excludes `.git`, `tmp`, `log`, `node_modules`, `spec`
- Precompile assets in build stage

## Production Readiness Checklist

Before going live:

- [ ] All tests pass, 80%+ coverage
- [ ] Brakeman and bundle audit clean
- [ ] Health check endpoint exists (`/up` or `/health`)
- [ ] Structured logging (JSON format for log aggregators)
- [ ] Error tracking configured (Sentry, Honeybadger, Rollbar)
- [ ] Database migrations are backward-compatible with current code
- [ ] Environment variables for all secrets
- [ ] Rate limiting configured (rack-attack)
- [ ] Monitoring and alerting set up (response times, error rates, queue depth)
- [ ] Rollback procedure documented and tested
- [ ] SSL/TLS enforced (`config.force_ssl = true`)
- [ ] Background job processor running (Sidekiq, GoodJob)

## Zero-Downtime Deploy Checklist

- Migrations don't lock tables (use concurrent indexes, expand-contract)
- New code works with both old and new schema during rollout
- No removed columns/tables until all instances run new code
- Health checks verify the app is ready to serve traffic
