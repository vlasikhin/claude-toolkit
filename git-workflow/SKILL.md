---
name: git-workflow
description: Git branching, commit, and merge conventions. Use when setting up a git workflow, writing commit messages, choosing a branching strategy, or resolving merge conflicts. Use when user says "git workflow", "commit message", "branching strategy", "conventional commits", or "merge vs rebase".
license: MIT
metadata:
  author: vlasikhin
  version: 1.0.0
---

# Git Workflow

Conventions for branching, commits, and merges. Pick one strategy and follow it consistently.

## Branching Strategies

### GitHub Flow (recommended for most teams)

- `main` is always deployable
- Feature branches from `main`: `feature/add-user-search`
- PR → review → merge → deploy
- Simple, fast iteration

### Trunk-Based Development (high-velocity teams)

- Short-lived branches (1-2 days max)
- Multiple deploys per day
- Feature flags hide work in progress
- Requires strong CI and test coverage

### GitFlow (scheduled releases)

- `main` for production, `develop` for integration
- Feature branches from `develop`
- Release branches for stabilization
- Hotfix branches from `main`
- More ceremony, suits enterprise release cycles

## Branch Naming

```
feature/short-description
fix/issue-number-description
chore/update-dependencies
docs/add-api-guide
```

Lowercase, hyphens, no spaces. Include ticket number if available: `fix/PROJ-123-login-timeout`.

## Conventional Commits

```
<type>(<scope>): <subject>
```

**Types:**
- `feat` — new feature
- `fix` — bug fix
- `docs` — documentation only
- `refactor` — code change that neither fixes a bug nor adds a feature
- `test` — adding or fixing tests
- `chore` — tooling, CI, dependencies
- `perf` — performance improvement
- `style` — formatting, whitespace (no logic change)

**Examples:**

```
feat(auth): add OAuth2 login with Google
fix(billing): prevent double-charge on retry
refactor(models): extract address validation to concern
test(orders): add edge cases for discount calculation
chore(deps): update Rails to 7.2.1
perf(queries): add composite index on posts(user_id, status)
```

**Rules:**
- Subject in imperative mood: "add", not "added" or "adds"
- No period at the end
- Max 72 characters for subject line
- Body (optional) explains why, not what

## Merge Strategy

- **Merge commits** for shared branches — preserves full history
- **Squash merge** for feature PRs — clean main history
- **Rebase** only for local, unpushed branches
- Never rebase pushed branches — it rewrites history and breaks collaborators

## PR Conventions

- One concern per PR — don't mix features with refactors
- Keep PRs under 400 lines when possible
- Write a description: what changed, why, how to test
- Link related issues
- Request review from at least one team member
- Don't merge your own PR on shared projects

## Commit Hygiene

- Commit early, commit often on feature branches
- Each commit should compile/pass tests (bisectable history)
- Don't commit generated files (build artifacts, compiled assets)
- Don't commit secrets, even temporarily — they persist in history
- Use `.gitignore` proactively
