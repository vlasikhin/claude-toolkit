---
name: ruby-gem-writer
description: Patterns for writing Ruby gems following Andrew Kane's battle-tested approach (100+ gems, 374M+ downloads). Use when creating new gems, designing gem APIs, or structuring Ruby libraries.
---

# Ruby Gem Writer

Simplicity over cleverness. Zero dependencies. Explicit code over metaprogramming. Rails integration without Rails coupling.

## Entry Point

`lib/gemname.rb` — always follows this order:

```ruby
require "forwardable"                          # 1. stdlib
require_relative "gemname/model"               # 2. internal files
require_relative "gemname/version"
require_relative "gemname/railtie" if defined?(Rails)  # 3. conditional Rails (LAST)

module GemName
  class Error < StandardError; end
  class ConfigError < Error; end

  class << self
    attr_accessor :timeout, :logger
    attr_writer :master_key
  end

  def self.master_key
    @master_key ||= ENV["GEMNAME_MASTER_KEY"]
  end

  self.timeout = 10
end
```

## Configuration

`class << self` with `attr_accessor`. No Configuration objects.

```ruby
module GemName
  class << self
    attr_accessor :timeout, :logger
  end
  self.timeout = 10
end
```

## Class Macro DSL

Single method call configures everything:

```ruby
class Product < ApplicationRecord
  searchkick word_start: [:name]
end
```

Implementation via `extend` + anonymous module:

```ruby
module GemName
  module Model
    def gemname(**options)
      unknown = options.keys - KNOWN_KEYWORDS
      raise ArgumentError, "unknown keywords: #{unknown.join(", ")}" if unknown.any?

      mod = Module.new do
        define_method(:some_method) { }
      end
      include mod

      class_eval do
        cattr_reader :gemname_options, instance_reader: false
        class_variable_set :@@gemname_options, options.dup
      end
    end
  end
end
```

## Rails Integration

Never require Rails gems directly. Always `ActiveSupport.on_load`:

```ruby
# lib/gemname/railtie.rb
module GemName
  class Railtie < Rails::Railtie
    initializer "gemname.configure" do
      ActiveSupport.on_load(:active_record) do
        extend GemName::Model
      end
    end

    rake_tasks do
      load "tasks/gemname.rake"
    end
  end
end
```

Use `prepend` for overriding Rails methods:

```ruby
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Migration.prepend(GemName::Migration)
end
```

Engine for mountable gems (PgHero, Blazer):

```ruby
class Engine < ::Rails::Engine
  isolate_namespace GemName
end
```

## Error Handling

Simple hierarchy. Validate early with `ArgumentError`:

```ruby
module GemName
  class Error < StandardError; end
  class ConfigError < Error; end
end

def initialize(key:)
  raise ArgumentError, "Key must be 32 bytes" unless key&.bytesize == 32
end
```

## Gemspec

Zero runtime dependencies. Dev deps in Gemfile, not gemspec:

```ruby
Gem::Specification.new do |spec|
  spec.name = "gemname"
  spec.version = GemName::VERSION
  spec.required_ruby_version = ">= 3.1"
  spec.files = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_path = "lib"
end
```

## File Layout

Simple gem:
```
lib/
├── gemname.rb
└── gemname/
    ├── model.rb
    └── version.rb
```

Complex gem (PgHero pattern — decompose by feature):
```
lib/
├── gemname.rb
└── gemname/
    ├── database.rb
    ├── engine.rb
    ├── version.rb
    └── methods/
        ├── indexes.rb
        ├── queries.rb
        └── connections.rb
```

## Database Adapters

Abstract base + adapter per DB. Detect via `connection.adapter_name`:

```ruby
def adapter
  case connection.adapter_name
  when /postg/i then Adapters::PostgreSQLAdapter.new(self)
  when /mysql|trilogy/i then Adapters::MySQLAdapter.new(self)
  else Adapters::AbstractAdapter.new(self)
  end
end
```

## Testing

Minitest only. No RSpec.

```ruby
# test/test_helper.rb
require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"
```

Multi-version testing via gemfiles in `test/gemfiles/`:

```ruby
# test/gemfiles/activerecord72.gemfile
source "https://rubygems.org"
gemspec path: "../../"
gem "activerecord", "~> 7.2.0"
```

## Anti-Patterns

- `method_missing` — use `define_method`
- Configuration objects — use class accessors
- Requiring Rails directly — use `ActiveSupport.on_load`
- `autoload` — use `require_relative`
- Committing `Gemfile.lock` in gems
- Many runtime dependencies

## References

See `references/` for detailed patterns:
- **[rails-integration.md](references/rails-integration.md)** — Railtie, Engine, on_load hooks
- **[database-adapters.md](references/database-adapters.md)** — multi-DB support
- **[testing-patterns.md](references/testing-patterns.md)** — CI, multi-version testing
