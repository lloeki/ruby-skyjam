$:.push File.expand_path("../lib", __FILE__)

require 'skyjam/version'

Gem::Specification.new do |s|
  s.name        = 'skyjam'
  s.version     = SkyJam::VERSION
  s.authors     = ['Loic Nageleisen']
  s.email       = ['loic.nageleisen@gmail.com']
  s.homepage    = 'http://byte.atrona.ch'
  s.summary     = 'Google Music API client'
  s.description = 'Google Music API client'

  s.files = Dir['{lib}/**/*'] + ['LICENSE', 'Rakefile', 'README.mdown']

  s.add_dependency 'protobuf'
  s.add_dependency 'oauth2'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rubocop'
end
