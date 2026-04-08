---
name: api-design
description: REST API design conventions for Rails applications. Use when designing API endpoints, choosing response formats, implementing pagination, or versioning APIs. Use when user says "design API", "REST endpoint", "API response format", "pagination", "API versioning", or "serialize response".
license: MIT
metadata:
  author: vlasikhin
  version: 1.0.0
---

# API Design

RESTful conventions for Rails APIs. Consistent, predictable, easy to consume.

## Resources

- Plural nouns: `/api/v1/users`, `/api/v1/posts`
- Nested for belongs_to: `/api/v1/users/:user_id/posts`
- Max one level of nesting — flatten deeper relationships
- No verbs in URLs (except `/auth/login`, `/auth/logout`)
- Kebab-case for multi-word: `/api/v1/line-items`

## HTTP Methods

| Method | Action | Success | Returns |
|---|---|---|---|
| GET | Read | 200 | Resource or collection |
| POST | Create | 201 | Created resource + `Location` header |
| PATCH | Partial update | 200 | Updated resource |
| PUT | Full replace | 200 | Updated resource |
| DELETE | Remove | 204 | Empty body |

## Status Codes

- **200** OK — successful GET, PATCH, PUT
- **201** Created — successful POST
- **204** No Content — successful DELETE
- **400** Bad Request — malformed JSON, missing required fields
- **401** Unauthorized — missing or invalid authentication
- **403** Forbidden — authenticated but not authorized
- **404** Not Found — resource doesn't exist
- **422** Unprocessable Entity — validation errors (with field details)
- **429** Too Many Requests — rate limit exceeded

Never wrap errors in 200. A failed request is a 4xx/5xx.

## Response Format

Single resource:

```json
{
  "data": {
    "id": 123,
    "type": "user",
    "email": "user@example.com",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

Collection with pagination:

```json
{
  "data": [...],
  "meta": {
    "page": 1,
    "per_page": 25,
    "total": 150
  }
}
```

Error:

```json
{
  "error": {
    "code": "validation_failed",
    "message": "Validation failed",
    "details": [
      { "field": "email", "message": "is already taken" }
    ]
  }
}
```

## Pagination

**Offset-based** — simple, good for admin panels and small datasets:

```
GET /api/v1/users?page=2&per_page=25
```

Use `kaminari` or `pagy` gem. Pagy is faster.

**Cursor-based** — stable for feeds, infinite scroll, large datasets:

```
GET /api/v1/events?after=abc123&limit=25
```

Use an encoded cursor (Base64 of ID or timestamp). Never expose raw IDs as cursors.

## Filtering and Sorting

Filters as query params:

```
GET /api/v1/users?status=active&role=admin
GET /api/v1/posts?created_after=2024-01-01
```

Sorting with `-` prefix for descending:

```
GET /api/v1/users?sort=-created_at,name
```

## Versioning

Version in URL path — simplest, most explicit:

```
namespace :api do
  namespace :v1 do
    resources :users
  end
end
```

When introducing v2: keep v1 working for at least 6 months. Return `Sunset` header with deprecation date.

## Serialization

Use a serializer gem — never return raw `to_json` on models:

- **Alba** — fast, flexible, recommended
- **Blueprinter** — simple DSL
- **jsonapi-serializer** — if you need JSON:API spec

```ruby
class UserSerializer
  include Alba::Resource

  attributes :id, :email, :name
  attribute :created_at do |user|
    user.created_at.iso8601
  end
end
```

## Authentication

- Bearer tokens in `Authorization` header: `Authorization: Bearer <token>`
- API keys for server-to-server in a separate header: `X-Api-Key: <key>`
- Never pass tokens in URL query params (they appear in logs)
- Return 401 with a clear error message when auth fails

## Rate Limiting

Return rate limit info in headers:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1704067200
```

Return 429 with `Retry-After` header when exceeded.
