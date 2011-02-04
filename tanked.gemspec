# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'tanked/version'

Gem::Specification.new do |s|
  s.name        = "tanked"
  s.version     = Tanked::GEM_VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = "Adam Kittelson"
  s.email       = "info@zencoder.com"
  s.homepage    = "http://github.com/zencoder/tanked"
  s.summary     = "Index Tank <http://indextank.com> Active Record etc integration library."
  s.description = "Index Tank <http://indextank.com> Active Record etc integration library."
  s.add_dependency "indextank"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "mocha"
  s.add_development_dependency "webmock"
  s.files        = Dir.glob("bin/**/*") + Dir.glob("lib/**/*") + %w(LICENSE README.markdown Rakefile)
  s.require_path = "lib"
end
