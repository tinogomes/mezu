module Mezu
  require "mezu/version"
  require "mezu/config"
  require "mezu/engine"

  extend self

  def models
    # Force load all models
    Dir["app/models/**/*.rb"].each do |f|
      begin
        f.gsub(%r[^app/models/(.*?)\.rb$], '\\1').classify.constantize
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
