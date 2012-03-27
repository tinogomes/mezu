ENV["RAILS_ENV"] = "test"
require "rails/all"
require "mezu"
require "support/config/boot"
require "rspec/rails"
require 'shoulda'

load File.dirname(__FILE__) + "/schema.rb"

module Helpers
  private
  def create_message(options = {})
    options.reverse_merge!(
      :title      => "title",
      :body       => "body",
      :level      => Mezu::Message::LEVELS.first,
      :expires_at => 5.days.from_now,
      :locale     => :en
    )
    Mezu::Message.create!(options)
  end
end

RSpec.configure do |config|
  config.include Helpers
  config.use_transactional_fixtures = true

  config.before do
    I18n.locale = :en
    Mezu::Config.available_locales = nil
    Mezu::Config.autoload_locales!
    Mezu::Config.authenticate = proc { true }
  end

  config.after do
    Mezu::Config.models = nil
  end
end

require_dependency "post"
require_dependency "user"

