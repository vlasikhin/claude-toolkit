---
name: dry-rb-patterns
description: dry-rb gem ecosystem patterns. Use when working with dry-monads, dry-validation, dry-schema, dry-types, dry-struct, dry-container, dry-auto_inject, dry-transaction, or dry-system. Use when user mentions "dry-monads", "Result monad", "dry-validation contract", or "service object with monads".
license: MIT
metadata:
  author: vlasikhin
  version: 1.0.0
---

# dry-rb Patterns

## dry-monads

Result monad for error handling without exceptions.

- Always include specific monads: `Dry::Monads[:result, :do]`
- Do notation: every yielded method must return `Success` or `Failure`
- Use `value_or` for safe unwrapping, never `value!` (raises on Failure)
- Use `fmap` to transform Success value, `bind` when returning another monad
- `Failure` with structured errors: `Failure[:not_found, id: 42]`
- Pattern matching for result handling: `case result in Success(value)` / `in Failure[:type, data]`

## dry-validation

Contracts = schema (type coercion) + rules (domain logic).

- `params` block for form input (coerces strings), `json` block for parsed JSON
- Rules only run if schema passes for that key
- Use `key?(:field)` in rules to check if optional key was provided
- Multi-key rules: `rule(:start_date, :end_date) { ... }`
- Base errors (not tied to a key): `base.failure('message')`
- Inject dependencies via `option`: `option :user_repo`
- Reusable macros: `register_macro(:email_format) { ... }` then `rule(:email).validate(:email_format)`

## dry-schema

Standalone schema validation and coercion (used inside contracts automatically).

- `Dry::Schema.Params` — coerces strings (form/query params)
- `Dry::Schema.JSON` — expects already-parsed types
- `filled` — present and non-empty; `value` — type check only; `maybe` — allows nil
- Unknown keys are stripped from output by default

## dry-types

Type system with coercion and constraints.

- Always define `module Types; include Dry.Types(); end` — with parentheses
- `optional` means value can be nil, not that the key can be omitted
- Default before enum: `Types::String.default('x').enum('x', 'y')`

## dry-struct

Typed immutable value objects.

- Structs are immutable — no setters
- `attribute?` — key can be omitted; `Types::X.optional` — value can be nil
- `transform_keys(&:to_sym)` for string key input
- Don't use for validation — validate first with dry-validation, then construct struct
- Nest structs: `attribute :address, Address`

## dry-container + dry-auto_inject

Dependency injection.

- Dot-separated keys become underscore methods: `"services.mailer"` → `services_mailer`
- Override in tests: `CreateUser.new(user_repo: mock_repo)`
- Call `finalize!` before resolving auto-registered components

## dry-transaction

Railway-oriented multi-step operations. Each step returns `Success`/`Failure`, short-circuits on first failure.

- Every step must return `Success` or `Failure` — plain values break the chain
- For new code prefer dry-monads Do notation directly — simpler and more flexible

## References

See `references/` for detailed code examples:
- **[examples.md](references/examples.md)** — full code examples for each dry-rb gem
