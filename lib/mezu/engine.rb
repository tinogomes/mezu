module Mezu
  class Engine < Rails::Engine
    generators do
      require "mezu/generators"
    end

    config.after_initialize do
      if Config.on_load
        Config.on_load[Config]
      end
    end
  end
end
