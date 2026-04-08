---
name: security-review
description: Security review checklist for Rails applications. Use when reviewing code for vulnerabilities, hardening a Rails app, or before deploying to production. Use when user says "security review", "check security", "harden this", "audit vulnerabilities", or "is this secure".
license: MIT
metadata:
  author: vlasikhin
  version: 1.0.0
---

# Security Review

Systematic checklist for Rails application security. Review each domain before shipping.

## 1. Secrets Management

- All secrets in `config/credentials.yml.enc` or environment variables
- Never hardcode API keys, tokens, passwords in source code
- `.gitignore` includes `.env`, `master.key`, `*.pem`
- Rotate compromised credentials immediately — don't just add new ones

## 2. Input Validation

- Strong Parameters on every controller action that accepts input
- Validate at model level: `presence`, `format`, `length`, `inclusion`
- Sanitize HTML input: `ActionView::Helpers::SanitizeHelper` or `Loofah`
- Reject unexpected content types — don't blindly parse JSON/XML from user

## 3. SQL Injection

- Always use parameterized queries: `where(name: params[:name])`
- Never interpolate: `where("name = '#{params[:name]}'"` is a vulnerability
- Watch for `order()`, `pluck()`, `select()` with raw user input
- Use `Arel` or `sanitize_sql_array` when raw SQL is unavoidable

## 4. Authentication

- Use `has_secure_password` or Devise — never roll your own password hashing
- Store sessions in encrypted cookies (Rails default) or server-side store
- Set `httponly: true`, `secure: true`, `SameSite: Lax` on session cookies
- Enforce password complexity and length (minimum 12 characters)
- Rate-limit login attempts

## 5. Authorization

- Check permissions on every action — not just in the UI
- Use `Current.user` scoping: `Current.user.posts.find(params[:id])` instead of `Post.find(params[:id])`
- Never trust client-side role checks — verify server-side
- Test authorization in request specs: ensure 403 for unauthorized access

## 6. XSS Protection

- Rails auto-escapes output in ERB by default — never use `raw` or `html_safe` on user content
- Set Content Security Policy in `config/initializers/content_security_policy.rb`
- Sanitize rich text: `sanitize(user_html, tags: %w[p br strong em])`
- Escape user input in JavaScript contexts: `escape_javascript` or JSON serialization

## 7. CSRF Protection

- `protect_from_forgery with: :exception` (Rails default)
- For API endpoints: use token-based auth instead of cookies, or verify CSRF token
- Set `SameSite` cookie attribute to prevent cross-origin requests
- Skip CSRF only on genuinely stateless API endpoints with `skip_forgery_protection`

## 8. Rate Limiting

- Use `rack-attack` gem for request throttling
- Throttle login attempts: 5 per minute per IP
- Throttle API endpoints: per-token limits
- Throttle password reset and signup: prevent enumeration

```ruby
Rack::Attack.throttle("logins/ip", limit: 5, period: 60.seconds) do |req|
  req.ip if req.path == "/login" && req.post?
end
```

## 9. Data Exposure

- Filter sensitive params from logs: `config.filter_parameters += [:password, :token, :secret, :ssn, :credit_card]`
- Never return full user records in API — serialize only needed fields
- Redact PII in error reports (Sentry, Honeybadger)
- Use `to_json(only: [:id, :name])` or serializer gems — never expose raw models

## 10. Dependencies

- Run `bundle audit` regularly — check for known CVEs
- Keep `Gemfile.lock` committed and reviewed in PRs
- Enable Dependabot or Renovate for automated updates
- Pin gem versions in Gemfile: `gem "rails", "~> 7.1.0"`
- Run `brakeman` as part of CI pipeline

## Automated Scanning

Run before every deploy:

```
bundle exec brakeman -q --no-pager
bundle audit check --update
```

Fail CI if either reports CRITICAL or HIGH severity issues.
