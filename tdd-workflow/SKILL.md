---
name: tdd-workflow
description: Test-driven development process for Ruby projects. Use when starting a new feature, fixing a bug test-first, or when user wants to follow TDD. Use when user says "TDD", "test first", "write tests first", "red green refactor", or "test-driven".
license: MIT
metadata:
  author: vlasikhin
  version: 1.0.0
---

# TDD Workflow

Red → Green → Refactor. Write the test before the code, every time.

## The Process

### Step 1: Define the Behavior

Write a user story or describe the expected behavior in plain English before touching any code.

"When a user submits a valid email, they receive a confirmation link."

### Step 2: Write the Test (RED)

Write a test that captures the behavior. Run it — it must fail. If it passes, the test is wrong or the feature already exists.

```ruby
RSpec.describe UserRegistration do
  it "sends confirmation email for valid input" do
    result = described_class.new(email: "user@example.com").call

    expect(result).to be_success
    expect(ActionMailer::Base.deliveries.last.to).to eq(["user@example.com"])
  end
end
```

### Step 3: Implement (GREEN)

Write the minimum code to make the test pass. Don't optimize. Don't handle edge cases yet. Just make it green.

### Step 4: Refactor

Now clean up — extract methods, rename variables, remove duplication. Tests stay green throughout. If a refactor breaks a test, undo and try a smaller change.

### Step 5: Repeat

Add the next test case — edge cases, error paths, boundary conditions. Each cycle: RED → GREEN → REFACTOR.

## Test Levels

Build from the inside out:

**Unit tests** — Models, service objects, plain Ruby classes. Fast, isolated, no external dependencies.

**Integration tests** — Request specs, controller actions, database interactions. Test that components work together.

**System tests** — Full browser tests with Capybara. Only for critical user flows. Slow, so keep the count low.

Ratio: many unit → fewer integration → few system.

## What to Test First

For a **new feature**: start with the happy path in a request spec, then add unit tests for business logic.

For a **bug fix**: write a test that reproduces the bug, verify it fails, then fix. The test proves the fix works and prevents regression.

For a **refactor**: ensure full test coverage before changing anything. If tests don't exist, write them first.

## Coverage

Target 80%+ on new code. Use SimpleCov:

```ruby
# spec/spec_helper.rb
require "simplecov"
SimpleCov.start "rails" do
  minimum_coverage 80
end
```

Coverage measures confidence, not completeness. 100% coverage with bad assertions is worthless.

## Edge Cases Checklist

Always test:
- Empty/nil input
- Boundary values (0, -1, max length, empty string)
- Duplicate submissions
- Unauthorized access
- Concurrent modifications (if applicable)
- Error responses from external services

## Anti-Patterns

- Writing tests after implementation (test-after is not TDD)
- Testing implementation details (private methods, internal state)
- Tests that pass regardless of behavior (tautological tests)
- Shared state between tests (one test's failure affects another)
- Slow tests as an excuse to skip them
