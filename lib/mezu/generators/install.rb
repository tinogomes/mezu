require "rails/generators/base"

module Mezu
  class InstallGenerator < ::Rails::Generators::Base
    source_root File.dirname(__FILE__) + "/../../../templates"

    def copy_initializer_file
      copy_file "initializer.rb", "config/initializers/mezu.rb"
    end

    def copy_migrations
      return if migration_exists?(:messages, :readings)

      stamp = proc {|time| time.utc.strftime("%Y%m%d%H%M%S")}

      [:messages, :readings].each_with_index do |name, i|
        copy_file "migration/#{name}.rb",
                  "db/migrate/#{stamp[i.second.from_now]}_create_mezu_#{name}.rb"
      end
    end

    def copy_assets
      FileUtils.mkdir_p "public/mezu"
      copy_file "mezu.css",  "public/mezu/mezu.css"
    end

    private
    def migration_exists?(*names)
      errors = []

      names.each do |name|
        migration = Dir["db/**/*_create_mezu_#{name}.rb"].first
        next unless migration

        errors << "Another migration is already named create_mezu_#{name}: #{migration}\n"
      end

      STDERR << errors.join if errors.any?
      errors.any?
    end
  end
end
