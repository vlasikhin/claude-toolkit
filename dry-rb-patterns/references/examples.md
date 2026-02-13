# dry-rb Examples

## dry-monads — Result monad

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

Pattern matching for result handling:

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

## dry-validation — Contract

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

## dry-schema — Standalone schema

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

## dry-types — Type definitions

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

## dry-struct — Typed value objects

```ruby
class User < Dry::Struct
  attribute :name, Types::String
  attribute :age, Types::Coercible::Integer
  attribute? :nickname, Types::String            # optional key
  attribute :role, Types::String.default('user')
end
```

## dry-container + dry-auto_inject — Dependency injection

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

## dry-transaction — Railway-oriented operations

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
