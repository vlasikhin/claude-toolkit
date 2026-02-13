---
name: rspec
description: RSpec testing conventions and patterns. Use when writing or reviewing RSpec tests in any Ruby project (Rails, plain Ruby, gems). Use when user asks to "write RSpec tests", "add specs", "test this with RSpec", or "review spec file".
license: MIT
metadata:
  author: vlasikhin
  version: 1.0.0
---

# RSpec Conventions

## Structure

- One `describe` per class/module, nested `describe` for methods
- Use `context` for different scenarios with `when`/`with`/`without` prefix
- One expectation per `it` block when practical
- `it` descriptions read as English: `it "returns nil when not found"`

```ruby
RSpec.describe User do
  describe "#full_name" do
    context "when both names present" do
      it "returns first and last name joined" do
        user = build(:user, first_name: "John", last_name: "Doe")
        expect(user.full_name).to eq("John Doe")
      end
    end
  end
end
```

## Setup

- Use `let` for lazy-evaluated data, `let!` only when record must exist before test runs
- Use `build` over `create` when persistence is not needed (faster)
- Use `build_stubbed` for unit tests that don't touch DB
- `subject` for the thing under test when used multiple times
- `before` for setup that isn't defining data (e.g. calling an action)
- Prefer `described_class` over hardcoded class name

## Factories (FactoryBot)

- Minimal valid factories — only required attributes
- Use traits for variations: `trait :published`, `trait :admin`
- Use sequences for unique fields: `sequence(:email) { |n| "user#{n}@example.com" }`
- Never use `create_list` with large counts in specs — keep it to 2-3

## Matchers

- `eq` for value equality, `be` for identity
- `be_valid` / `be_invalid` for model validation specs
- `change { ... }.from(...).to(...)` for state changes
- `have_enqueued_job` for async job testing
- `include` for partial collection/hash matching
- `raise_error(SpecificError)` — always specify error class

## Rails-specific

- Request specs over controller specs
- Use `have_http_status(:ok)` for response codes
- Test JSON response: `JSON.parse(response.body)`
- Use `travel_to` for time-dependent tests
- Wrap DB-modifying tests in transactions (default with `use_transactional_fixtures`)

## Mocking

- Prefer real objects over mocks
- Use `instance_double` with verified doubles
- Mock external services and APIs, not internal classes
- Use `allow(...).to receive(...)` for stubs
- Use `expect(...).to have_received(...)` for spy-style verification

## Organization

- Mirror `app/` structure in `spec/`: `spec/models/`, `spec/services/`, `spec/requests/`
- Shared examples for common behavior: `it_behaves_like "authenticatable"`
- Shared contexts for common setup
- `spec/support/` for helpers and shared configs
