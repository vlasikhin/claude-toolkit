# Testing Patterns

## Setup

```ruby
# test/test_helper.rb
require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"
require "gemname"

ActiveRecord::Base.establish_connection(
  ENV["DATABASE_URL"] || { adapter: "postgresql", database: "gemname_test" }
)

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :email
    t.timestamps
  end
end

class User < ActiveRecord::Base
  gemname_feature :email
end
```

## Test Structure

```ruby
class ModelTest < Minitest::Test
  def setup
    User.delete_all
  end

  def test_basic_functionality
    user = User.create!(email: "test@example.org")
    assert_equal "test@example.org", user.email
  end

  def test_with_invalid_input
    error = assert_raises(ArgumentError) { User.create!(email: nil) }
    assert_match /email/, error.message
  end
end
```

## Multi-Version Testing

```
test/gemfiles/
├── activerecord70.gemfile
├── activerecord71.gemfile
└── activerecord72.gemfile
```

```ruby
# test/gemfiles/activerecord72.gemfile
source "https://rubygems.org"
gemspec path: "../../"
gem "activerecord", "~> 7.2.0"
```

```bash
BUNDLE_GEMFILE=test/gemfiles/activerecord72.gemfile bundle exec rake test
```

## Rakefile

```ruby
require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

task default: :test
```

## GitHub Actions CI

```yaml
name: build
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        include:
          - ruby: "3.2"
            gemfile: activerecord70
          - ruby: "3.3"
            gemfile: activerecord72
    env:
      BUNDLE_GEMFILE: test/gemfiles/${{ matrix.gemfile }}.gemfile
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby }}
          bundler-cache: true
      - run: bundle exec rake test
```

## Test Helpers

```ruby
class Minitest::Test
  def with_options(options)
    original = GemName.options.dup
    GemName.options.merge!(options)
    yield
  ensure
    GemName.options = original
  end

  def assert_queries(expected_count)
    queries = []
    callback = ->(*, payload) { queries << payload[:sql] }
    ActiveSupport::Notifications.subscribe("sql.active_record", callback)
    yield
    assert_equal expected_count, queries.size
  ensure
    ActiveSupport::Notifications.unsubscribe(callback)
  end
end
```
