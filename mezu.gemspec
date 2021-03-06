# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mezu/version"

Gem::Specification.new do |s|
  s.name        = "mezu"
  s.version     = Mezu::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tino Gomes", "Nando Vieira"]
  s.email       = ["tinorj@gmail.com", "fnando.vieira@gmail.com"]
  s.homepage    = "http://github.com/tinogomes/mezu"
  s.summary     = %q{Mezu is a Rails 3 Engine that manages system messages globally, or for a specific object.}
  s.description = s.summary

  s.rubyforge_project = "mezu"

  s.files         = Dir["./**/*"].reject {|file| file =~ /\.git|pkg/}
  s.require_paths = ["lib"]

  s.add_dependency "rails", "~> 3.0"
  s.add_dependency "arel", "~> 3.0.2"

  s.add_development_dependency "ruby-debug19"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec-rails", "~> 2.4.1"
  s.add_development_dependency "shoulda", "~> 3.0.0"
  s.add_development_dependency "sqlite3-ruby", "~> 1.3.2"
end
