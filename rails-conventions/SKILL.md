---
name: rails-conventions
description: Rails framework conventions and patterns. Use when working in a Rails project — writing controllers, models, migrations, services, jobs, or any Rails-specific code.
---

# Rails Conventions

## Controllers

- Thin controllers — only params, auth, and response rendering
- Use `before_action` for shared logic (set_resource, authenticate, authorize)
- Strong parameters in private methods
- Respond with proper HTTP status codes (`:created`, `:unprocessable_entity`, `:no_content`)
- Rescue `ActiveRecord::RecordNotFound` to return 404
- Never put business logic in controllers — extract to service objects

## Models

- Validations at model level, not in controllers
- Use `presence`, `uniqueness`, `format`, `length` validations with appropriate constraints
- Define scopes for reusable queries: `scope :published, -> { where(status: :published) }`
- Use `enum` for finite state fields with explicit integer mapping: `enum status: { draft: 0, published: 1 }`
- Avoid callbacks for side effects — prefer service objects
- Acceptable callbacks: `before_save` for data normalization (downcase email, strip whitespace)
- Use `dependent: :destroy` or `:nullify` on associations — never leave orphans
- Keep models focused: associations, validations, scopes, simple instance methods

## Migrations

- Always set `null: false` on required columns
- Always set `default:` on boolean and enum columns
- Use `references` with `foreign_key: true` for associations
- Add indexes on foreign keys and columns used in WHERE/ORDER
- Composite indexes for common query patterns: `add_index :posts, [:user_id, :status]`
- Use `change` method when reversible, `up/down` when not

## Services

- Plain Ruby classes in `app/services/`
- Single public method: `call` (class method or instance)
- Name describes the action: `CreateUser`, `PublishPost`, `ArchiveOldDrafts`
- Return result object or raise on failure
- Inject dependencies through constructor when testable

```ruby
class PublishPost
  def initialize(post, user:)
    @post = post
    @user = user
  end

  def call
    authorize!
    @post.update!(status: :published, published_at: Time.current)
    NotifySubscribersJob.perform_later(@post)
    @post
  end
end
```

## Queries

- Always use `includes` or `preload` to avoid N+1
- Use `find_each` for batch processing, never `all.each`
- Parameterize all user input: `where("title ILIKE ?", "%#{query}%")`
- Extract complex queries to scope or query object
- Use `exists?` instead of `present?` for checking records
- Use `pluck` when you only need specific columns
- Use `size` on loaded relations, `count` for SQL COUNT

## Background Jobs

- Inherit from `ApplicationJob`
- Keep jobs idempotent — safe to retry
- Pass IDs, not objects (objects can't be serialized reliably)
- Use `perform_later` by default, `perform_now` only when synchronous is required
- Set appropriate queue: `queue_as :default`

## Routes

- RESTful resources by default
- Namespace API versions: `namespace :api { namespace :v1 { ... } }`
- Use `member` and `collection` routes for non-CRUD actions
- Keep routes file readable — extract to `draw` files if large

## General

- Follow Rails conventions over custom solutions
- Use `Time.current` instead of `Time.now` (respects timezone)
- Use `Rails.logger` for logging, never `puts`
- Never hardcode secrets — use credentials or environment variables
- Prefer `Hash#fetch` over `Hash#[]` when key must exist
