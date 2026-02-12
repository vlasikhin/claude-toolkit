---
name: dry-rb-patterns
description: dry-rb gem ecosystem patterns. Use when working with dry-monads, dry-validation, dry-schema, dry-types, dry-struct, dry-container, dry-auto_inject, dry-transaction, or dry-system.
---

# dry-rb Patterns

## dry-monads

Result monad for error handling without exceptions.

```ruby
class CreateUser
  include Dry::Monads[:result, :do]

  def call(params)
    values = yield validate(params)
    user = yield persist(values)
    Success(user)
  end
end
```

- Always include specific monads: `Dry::Monads[:result, :do]`
- Do notation: every yielded method must return `Success` or `Failure`
- Use `value_or` for safe unwrapping, never `value!` (raises on Failure)
- Use `fmap` to transform Success value, `bind` when returning another monad
- `Failure` with structured errors: `Failure[:not_found, id: 42]`
- Pattern matching for result handling:

```ruby
case result
in Success(user)
  render_user(user)
in Failure[:validation, errors]
  render_errors(errors)
in Failure[:not_found, *]
  render_404
end
```

## dry-validation

Contracts = schema (type coercion) + rules (domain logic).

```ruby
class NewUserContract < Dry::Validation::Contract
  params do
    required(:email).filled(:string)
    required(:age).filled(:integer, gt?: 18)
    optional(:nickname).filled(:string)
  end

  rule(:email) do
    key.failure('has invalid format') unless /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.match?(value)
  end
end

result = NewUserContract.new.call(params)
result.success?     # => true/false
result.errors.to_h  # => { email: ["has invalid format"] }
```

- `params` block for form input (coerces strings), `json` block for parsed JSON
- Rules only run if schema passes for that key
- Use `key?(:field)` in rules to check if optional key was provided
- Multi-key rules: `rule(:start_date, :end_date) { ... }`
- Base errors (not tied to a key): `base.failure('message')`
- Inject dependencies via `option`: `option :user_repo`
- Reusable macros: `register_macro(:email_format) { ... }` then `rule(:email).validate(:email_format)`

## dry-schema

Standalone schema validation and coercion (used inside contracts automatically).

```ruby
schema = Dry::Schema.Params do
  required(:name).filled(:string)
  required(:age).filled(:integer, gt?: 0)
  required(:tags).array(:str?)
  required(:address).hash do
    required(:city).filled(:string)
  end
end
```

- `Dry::Schema.Params` — coerces strings (form/query params)
- `Dry::Schema.JSON` — expects already-parsed types
- `filled` — present and non-empty; `value` — type check only; `maybe` — allows nil
- Unknown keys are stripped from output by default

## dry-types

Type system with coercion and constraints.

```ruby
module Types
  include Dry.Types()
end

Types::String                                    # nominal
Types::Strict::String                            # raises on wrong type
Types::Coercible::Integer                        # coerces ("18" => 18)
Types::String.constrained(min_size: 3)           # with constraint
Types::String.default('draft')                   # with default
Types::Integer.optional                          # allows nil
Types::String.enum('draft', 'published')         # enum
```

- Always define `module Types; include Dry.Types(); end` — with parentheses
- `optional` means value can be nil, not that the key can be omitted
- Default before enum: `Types::String.default('x').enum('x', 'y')`

## dry-struct

Typed immutable value objects.

```ruby
class User < Dry::Struct
  attribute :name, Types::String
  attribute :age, Types::Coercible::Integer
  attribute? :nickname, Types::String            # optional key
  attribute :role, Types::String.default('user')
end
```

- Structs are immutable — no setters
- `attribute?` — key can be omitted; `Types::X.optional` — value can be nil
- `transform_keys(&:to_sym)` for string key input
- Don't use for validation — validate first with dry-validation, then construct struct
- Nest structs: `attribute :address, Address`

## dry-container + dry-auto_inject

Dependency injection.

```ruby
class App < Dry::System::Container
  configure do |config|
    config.root = Pathname('./my/app')
    config.component_dirs.add 'lib'
  end
end

Import = App.injector

class CreateUser
  include Import['user_repo', 'services.mailer']

  def call(attrs)
    user = user_repo.create(attrs)
    services_mailer.welcome(user)
    user
  end
end
```

- Dot-separated keys become underscore methods: `"services.mailer"` → `services_mailer`
- Override in tests: `CreateUser.new(user_repo: mock_repo)`
- Call `finalize!` before resolving auto-registered components

## dry-transaction

Railway-oriented multi-step operations. Each step returns `Success`/`Failure`, short-circuits on first failure.

```ruby
class CreateOrder
  include Dry::Transaction

  step :validate
  step :persist
  step :notify

  private

  def validate(input)
    # must return Success(value) or Failure(value)
  end
end
```

- Every step must return `Success` or `Failure` — plain values break the chain
- For new code prefer dry-monads Do notation directly — simpler and more flexible

## Common Service Object Pattern

```ruby
class CreateUser
  include Dry::Monads[:result, :do]

  def call(params)
    values = yield validate(params)
    user = yield persist(values)
    yield notify(user)
    Success(user)
  end

  private

  def validate(params)
    result = NewUserContract.new.call(params)
    result.success? ? Success(result.to_h) : Failure[:validation, result.errors.to_h]
  end

  def persist(values)
    Success(UserRepo.new.create(values))
  rescue StandardError => e
    Failure[:persist, e.message]
  end

  def notify(user)
    UserMailer.welcome(user).deliver_later
    Success(user)
  end
end
```
