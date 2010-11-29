module Mezu
  def self.configure(&block)
    Config.on_load = block
  end

  module Config
    class << self
      attr_accessor :authenticate, :on_load
    end

    def self.autoload_locales!
      Dir[File.dirname(__FILE__) + "/../../templates/locales/*.yml"].each do |file|
        locale = File.basename(file).delete(".yml")
        I18n.load_path << File.expand_path(file)
      end

      Mezu.reload_translations!
    end
  end
end
