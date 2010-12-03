require "rails/generators/base"

module Mezu
  class CopyLocalesGenerator < ::Rails::Generators::Base
    source_root File.dirname(__FILE__) + "/../../../templates"

    def copy_locales
      copy_file "locales/mezu.en.yml", "config/locales/mezu.en.yml"
      copy_file "locales/mezu.pt-BR.yml", "config/locales/mezu.pt-BR.yml"
    end
  end
end
