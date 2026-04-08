---
name: rails-code-review
description: Detailed Rails code review covering services, models, controllers, queries, jobs, presenters, and tests. Use when reviewing Ruby/Rails code changes, before merging a PR, or when user says "code review", "review my changes", "check this PR", or "review Rails code". Load references/review-rules.md for the full review rulebook.
license: MIT
metadata:
  author: vlasikhin
  version: 1.0.0
---

# Rails Code Review

## When to Apply

- User asks for code review or to check changes
- Before merging a PR with Ruby file changes
- After confirming tests pass (`bundle exec rspec`)

**Do not apply** if changes only touch configs, docs, or non-Ruby files.

## Goal

Improve the codebase: give **detailed** feedback including naming, duplication, responsibility boundaries, and tests. Don't limit yourself to only critical issues.

## Review Areas

All Rails layers: services, contracts, controllers, models, presenters, policies, jobs, consumers. Plus:

- N+1 queries, dead code, leftover `puts`/`binding.pry`/`debugger`
- Test presence and relevance for changed code
- Consistency with project conventions

## What NOT to Flag

- Purely taste-based preferences that don't improve readability, reliability, or maintainability
- Premature performance optimizations without evidence of a real problem
- If a comment wouldn't survive the question "what breaks or becomes confusing if we leave it as-is?" — don't write it

## Feedback Format

Structured response with file:line references:

### Summary
Brief: what changed, overall verdict.

### Critical
Must fix before merge — bugs, security, architecture violations, missing tests. Inaccurate docs are not a blocker, only a suggestion.

- `app/services/.../create.rb:42` — [description]. Suggestion: ...

### Recommendations
Style, readability, naming, duplication improvements.

- `app/controllers/...` — [description]. Suggestion: ...

### Minor
Formatting, consistency. If none — write "None".

## How to Formulate Feedback

- Criticize the **specific risk**, not the style itself: confusing main flow, business rule in wrong layer, N+1 hidden by structure, presentation layer doing DB work, comment diverging from reality
- If suggesting an alternative, make it **simpler and more explicit**, not just "different"
- If the issue is about a convention, explain **which reader expectation is currently violated**
- If the decision depends on external context, add a brief explanation rather than hoping it's "obvious"

## Detailed Review Rules

For the full 10-category review rulebook, read `references/review-rules.md`. It covers:
1. API design and method signatures
2. Naming and misleading formulations
3. Code simplification
4. Test quality and structure
5. Flow control and error handling
6. Comments and documentation
7. Query and SQL patterns
8. Presentation layer boundaries
9. Performance (data-driven only)
10. Ruby conventions
