---
name: verification-loop
description: Pre-commit verification checklist for Rails projects. Use when preparing code for review, running quality checks, or before merging a PR. Use when user says "verify this", "run checks", "pre-commit check", "quality gate", "is this ready to merge", or "CI checks".
license: MIT
metadata:
  author: vlasikhin
  version: 1.0.0
---

# Verification Loop

Six-phase quality gate. Run all phases before pushing. Stop and fix at the first failure — don't accumulate errors.

## Phase 1: Build

Ensure the application loads without errors.

```
bundle exec rails runner "puts 'OK'"
```

For gems: `bundle exec ruby -e "require 'your_gem'"`. Catches missing requires, syntax errors, broken initializers.

## Phase 2: Type Check (if applicable)

```
bundle exec srb tc          # Sorbet
bundle exec steep check      # RBS/Steep
```

Skip if the project doesn't use type checking. Don't introduce type checking just for this step.

## Phase 3: Lint

```
bundle exec rubocop --force-exclusion
```

Fix violations before proceeding. Use `rubocop -A` for safe auto-corrections only. Review unsafe corrections manually.

For ERB templates: `bundle exec erb_lint --lint-all`

## Phase 4: Tests

```
bundle exec rspec            # or bundle exec rails test
```

Target: all tests pass. Coverage: 80%+ on changed code.

Run the full suite, not just files you changed — catch regressions.

## Phase 5: Security

```
bundle exec brakeman -q --no-pager
bundle audit check --update
```

Brakeman catches Rails-specific vulnerabilities. Bundle audit checks gem CVEs. Fix CRITICAL and HIGH issues before merging.

## Phase 6: Diff Review

Review your own changes before pushing:

```
git diff --stat
git diff
```

Check for:
- Debugging code (`binding.pry`, `puts`, `debugger`, `console.log`)
- Hardcoded secrets or credentials
- Unintended file changes
- TODO/FIXME that should be resolved before merge
- Commented-out code that should be deleted

## Shortcuts

When changing only a specific area, you can scope tests:

```
bundle exec rspec spec/models/user_spec.rb    # single file
bundle exec rspec spec/models/                 # directory
bundle exec rspec --tag focus                  # focused tests
```

But always run the full suite before the final push.

## CI Integration

All six phases should run in CI. Fail the build on any phase failure. Typical GitHub Actions order:

1. `bundle install`
2. `bundle exec rubocop`
3. `bundle exec rspec`
4. `bundle exec brakeman -q`
5. `bundle audit check`
