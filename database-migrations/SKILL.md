---
name: database-migrations
description: Safe database migration patterns for Rails. Use when writing migrations for production databases, adding columns to large tables, or planning schema changes. Use when user says "write migration", "safe migration", "add column", "add index", "zero-downtime migration", or "strong_migrations".
license: MIT
metadata:
  author: vlasikhin
  version: 1.0.0
---

# Database Migrations

Safe migration patterns for Rails production databases. Assume every migration runs on a live, high-traffic system.

## Five Rules

1. **Version control all schema changes** — no manual production edits
2. **Forward-only in production** — fix mistakes with new migrations, never edit deployed ones
3. **Separate DDL from DML** — schema changes and data migrations in different files
4. **Test at production scale** — a migration fast on 1K rows can lock a 10M-row table
5. **Immutability** — deployed migrations are frozen, even if they have bugs

## Dangerous Operations

These require special handling on large tables:

| Operation | Risk | Safe Alternative |
|---|---|---|
| `add_column` with default | Table rewrite (PG < 11) | PG 11+ handles this safely; for older versions add column then set default |
| `add_index` | Table lock | `add_index :table, :col, algorithm: :concurrently` |
| `remove_column` | App errors during deploy | Stop reading column first, deploy, then remove |
| `rename_column` | Breaks running app | Add new column → copy data → drop old (expand-contract) |
| `change_column_null` | Full table scan | Add check constraint first, then validate separately |
| `add_foreign_key` | Lock + validate | `add_foreign_key :a, :b, validate: false` then `validate_foreign_key :a, :b` |

## Concurrent Indexes

Always create indexes concurrently on existing tables:

```ruby
class AddIndexToUsersEmail < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :users, :email, algorithm: :concurrently
  end
end
```

`disable_ddl_transaction!` is required — concurrent indexes cannot run inside a transaction.

## Expand-Contract Pattern

For breaking changes, deploy in phases:

**Phase 1 — Expand:** Add new column, dual-write to both old and new
**Phase 2 — Migrate:** Backfill data in batches, switch reads to new column
**Phase 3 — Contract:** Remove old column after all code uses new one

Each phase is a separate deploy. Never combine them.

## Batch Data Migrations

Never update all rows in one statement. Use batches:

```ruby
User.in_batches(of: 1000) do |batch|
  batch.update_all(status: "active")
end
```

For complex transformations, use a separate rake task or data migration gem — not a schema migration.

## strong_migrations Gem

Add `strong_migrations` to catch unsafe operations automatically:

```ruby
gem "strong_migrations"
```

It blocks dangerous operations and suggests safe alternatives. Follow its suggestions.

## Column Removal Checklist

1. Remove all code references to the column
2. Add column to `ignored_columns`:
   ```ruby
   class User < ApplicationRecord
     self.ignored_columns += ["legacy_field"]
   end
   ```
3. Deploy and verify
4. Write migration to drop the column
5. Deploy migration
6. Remove `ignored_columns` entry

## Backfill Best Practices

- Run during low-traffic hours
- Use `in_batches` with small batch sizes (500-1000)
- Add progress logging
- Make backfills idempotent — safe to re-run
- Test on a staging copy of production data first
