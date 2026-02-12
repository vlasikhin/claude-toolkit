---
name: ruby-style
description: Ruby code style conventions and idioms. Use when writing, reviewing, or refactoring any Ruby code. Covers naming, formatting, structure, and idiomatic patterns.
---

# Ruby Style

## Formatting

- `frozen_string_literal: true` at the top of every file
- 2 spaces indentation, no tabs
- Max 120 characters per line
- Single empty line between method definitions
- No trailing whitespace
- Newline at end of file

## Strings

- Single quotes for plain strings: `'hello'`
- Double quotes only when interpolation or escape sequences needed: `"Hello, #{name}"`
- Heredoc for multiline strings with `~` for indentation stripping:

```ruby
<<~SQL
  SELECT * FROM users
  WHERE active = true
SQL
```

## Naming

- `snake_case` for methods, variables, files
- `CamelCase` for classes and modules
- `SCREAMING_SNAKE_CASE` for constants
- Predicate methods end with `?`: `active?`, `valid?`
- Dangerous methods end with `!`: `save!`, `destroy!`
- Prefix unused block args with `_`: `map { |_key, value| value }`

## Methods

- Max 5 lines per method (Sandi Metz rule) — extract when longer
- Max 100 lines per class
- Guard clauses over nested conditionals:

```ruby
def process(user)
  return unless user.active?

  do_work(user)
end
```

- Keyword arguments over positional when 2+ params:

```ruby
def create_user(name:, email:, role: :member)
```

- Omit parentheses for methods with no args: `def name`
- Use parentheses for methods with args: `def name(first, last)`
- Omit `return` for last expression

## Blocks

- `{ }` for single-line blocks: `users.map { |u| u.name }`
- `do...end` for multi-line blocks
- Symbol-to-proc shorthand when applicable: `users.map(&:name)`

## Collections

- `map` over `collect`
- `detect` / `find` over `select { ... }.first`
- `select` / `reject` over manual filtering
- `each_with_object` over `inject`/`reduce` for building hashes/arrays
- `flat_map` over `map { ... }.flatten`
- `any?` / `none?` / `all?` with block over manual iteration
- `count` with block over `select { ... }.size`

## Conditionals

- `unless` for simple negative conditions, never with `else`
- Ternary for simple assignments: `status = active? ? 'on' : 'off'`
- `case/in` pattern matching for complex branching (Ruby 3+)
- No `and`/`or` — use `&&`/`||`
- `if` modifier for single-line: `raise NotFound if user.nil?`

## Error Handling

- Rescue specific exceptions, never bare `rescue`
- `StandardError` as the broadest acceptable rescue
- Custom errors inherit from `StandardError`
- Use `raise`, never `fail`

```ruby
class NotFoundError < StandardError; end

begin
  find_user!(id)
rescue NotFoundError => e
  log_error(e)
end
```

## Classes

- One class per file
- Organize class body: constants, includes, attr_*, validations, callbacks, class methods, public methods, private methods
- `attr_reader` over manual getters
- `private` keyword once, not per-method
- Prefer composition over inheritance
- Freeze mutable constants: `STATUSES = %w[draft published].freeze`

## Misc

- `Hash#fetch` when key must exist, `Hash#[]` when nil is acceptable
- `Array()` / `Hash()` for safe coercion
- `freeze` string constants and array/hash constants
- Prefer `%w[]` for word arrays, `%i[]` for symbol arrays
- `===` is for case statements only, never for comparison
