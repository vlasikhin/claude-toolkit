---
name: minitest
description: Minitest testing conventions and patterns. Use when writing or reviewing Minitest tests in Ruby projects. Covers both Minitest::Test and Minitest::Spec styles. Use when user asks to "write Minitest tests", "add test cases", "test with Minitest", or "review test file".
license: MIT
metadata:
  author: vlasikhin
  version: 1.0.0
---

# Minitest Conventions

## Style

- Prefer `Minitest::Test` (assert style) for Rails default projects
- Use `Minitest::Spec` (describe/it) when team prefers BDD syntax
- Don't mix styles within a project

## Test Structure (Minitest::Test)

- Class names end with `Test`: `class UserTest < ActiveSupport::TestCase`
- Method names start with `test_`: `def test_full_name_returns_joined_names`
- Group related tests with comments if needed

```ruby
class UserTest < ActiveSupport::TestCase
  def test_valid_with_required_attributes
    user = build(:user)
    assert user.valid?
  end

  def test_invalid_without_email
    user = build(:user, email: nil)
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end
end
```

## Spec Structure (Minitest::Spec)

```ruby
describe User do
  describe "#full_name" do
    it "returns first and last name" do
      user = build(:user, first_name: "John", last_name: "Doe")
      _(user.full_name).must_equal "John Doe"
    end
  end
end
```

## Assertions

- `assert` / `assert_not` for boolean checks
- `assert_equal expected, actual` (expected first)
- `assert_nil` / `assert_not_nil`
- `assert_includes collection, item`
- `assert_raises(SpecificError) { ... }` — always specify error class
- `assert_difference "User.count", 1 do ... end` for DB record changes
- `assert_no_difference` when count should not change
- `assert_enqueued_with(job: MyJob)` for background jobs

## Fixtures vs Factories

- Rails default: fixtures in `test/fixtures/`
- Fixtures for stable reference data, factories for test-specific variations
- If using FactoryBot with Minitest: include `FactoryBot::Syntax::Methods` in test helper

## Setup / Teardown

- `setup` method for common test data
- `teardown` for cleanup (rarely needed with transactions)
- Keep setup minimal — each test should be understandable on its own

## Rails Integration Tests

- Use `ActionDispatch::IntegrationTest` for request-level testing
- `get`, `post`, `patch`, `delete` for HTTP verbs
- `assert_response :success` / `:not_found` / `:unprocessable_entity`
- `JSON.parse(response.body)` for API response parsing
- `travel_to` for time-dependent tests

## Organization

- Mirror `app/` structure: `test/models/`, `test/services/`, `test/integration/`
- Shared behavior via modules in `test/support/`
- `test/test_helper.rb` for global config
