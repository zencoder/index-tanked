# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'index-tanked/version'

Gem::Specification.new do |s|
  s.name        = "index-tanked"
  s.version     = IndexTanked::GEM_VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = "Adam Kittelson"
  s.email       = "info@zencoder.com"
  s.homepage    = "http://github.com/zencoder/index-tanked"
  s.summary     = "Index Tank <http://indextank.com> Active Record etc integration library."
  s.description = "Provides methods for indexing objects to Index Tank. Extra convenience methods included for Active Record objects."
  s.add_dependency "indextank"
  s.add_dependency "will_paginate", '~>2.3'
  s.add_development_dependency "shoulda"
  s.add_development_dependency "mocha"
  s.add_development_dependency "webmock"
  s.files        = Dir.glob("bin/**/*") + Dir.glob("lib/**/*") + %w(LICENSE README.markdown Rakefile)
  s.require_path = "lib"
end
