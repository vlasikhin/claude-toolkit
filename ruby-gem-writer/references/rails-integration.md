# Rails Integration Patterns

## ActiveSupport.on_load Hooks

```ruby
ActiveSupport.on_load(:active_record) do
  extend GemName::Model            # class methods
  include GemName::Callbacks       # instance methods
end

ActiveSupport.on_load(:action_controller) do
  include GemName::Controller
end

ActiveSupport.on_load(:active_job) do
  include GemName::JobExtensions
end
```

## Railtie (Non-mountable)

```ruby
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

## Engine (Mountable — PgHero, Blazer)

```ruby
module GemName
  class Engine < ::Rails::Engine
    isolate_namespace GemName

    initializer "gemname.assets", group: :all do |app|
      if app.config.respond_to?(:assets) && defined?(Sprockets)
        app.config.assets.precompile << "gemname/application.js"
        app.config.assets.precompile << "gemname/application.css"
      end
    end
  end
end
```

## Prepend for Behavior Modification

```ruby
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Migration.prepend(GemName::Migration)
  ActiveRecord::Migrator.prepend(GemName::Migrator)
end
```

## Conditional Feature Detection

```ruby
if ActiveRecord.version >= Gem::Version.new("7.0")
  # Rails 7+ specific
end

def self.client
  @client ||= if defined?(OpenSearch::Client)
    OpenSearch::Client.new
  elsif defined?(Elasticsearch::Client)
    Elasticsearch::Client.new
  else
    raise Error, "Install elasticsearch or opensearch-ruby"
  end
end
```

## YAML Config with ERB

```ruby
def self.settings
  @settings ||= begin
    path = Rails.root.join("config", "gemname.yml")
    path.exist? ? YAML.safe_load(ERB.new(File.read(path)).result, aliases: true) : {}
  end
end
```

## Generator

```ruby
module GemName
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_initializer
        template "initializer.rb", "config/initializers/gemname.rb"
      end

      def copy_migration
        migration_template "migration.rb", "db/migrate/create_gemname_tables.rb"
      end
    end
  end
end
```
