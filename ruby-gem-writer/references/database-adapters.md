# Database Adapter Patterns

## Abstract Base

```ruby
module GemName
  module Adapters
    class AbstractAdapter
      def initialize(checker)
        @checker = checker
      end

      def min_version = nil
      def set_statement_timeout(timeout) = nil

      private

      def connection = @checker.send(:connection)
      def quote(value) = connection.quote(value)
    end
  end
end
```

## PostgreSQL Adapter

```ruby
module GemName
  module Adapters
    class PostgreSQLAdapter < AbstractAdapter
      def min_version = "12"

      def set_statement_timeout(timeout)
        select_all("SET statement_timeout = #{timeout.to_i * 1000}")
      end

      def set_lock_timeout(timeout)
        select_all("SET lock_timeout = #{timeout.to_i * 1000}")
      end

      private

      def select_all(sql) = connection.select_all(sql)
    end
  end
end
```

## Adapter Detection

```ruby
def adapter
  case connection.adapter_name
  when /postg/i
    Adapters::PostgreSQLAdapter.new(self)
  when /mysql|trilogy/i
    connection.try(:mariadb?) ? Adapters::MariaDBAdapter.new(self) : Adapters::MySQLAdapter.new(self)
  when /sqlite/i
    Adapters::SQLiteAdapter.new(self)
  else
    Adapters::AbstractAdapter.new(self)
  end
end
```

## Multi-Database Support

```ruby
module GemName
  class << self
    attr_accessor :databases
  end
  self.databases = {}

  def self.primary_database = databases.values.first

  class Database
    attr_reader :id, :config

    def initialize(id, config)
      @id = id
      @config = config
    end

    def connection_model
      @connection_model ||= Class.new(ActiveRecord::Base) { self.abstract_class = true }.tap do |model|
        model.establish_connection(config)
      end
    end

    def connection = connection_model.connection
  end
end
```
