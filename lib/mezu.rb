module Mezu
  require "mezu/version"
  require "mezu/config"
  require "mezu/engine"

  extend self

  def models
    return Config.models if Config.models
    # Force load all models
    Dir["app/models/**/*.rb"].each do |f|
      begin
        load f
      rescue
        nil
      end
    end
    ActiveRecord::Base.descendants.map(&:name).reject {|m| m.start_with?("Mezu::")}
  end

  def reload_translations!
    ::I18n.backend.instance_eval do
      init_translations
    end
  end
end
