$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'skyjam/version'

Gem::Specification.new do |s|
  s.name        = 'skyjam'
  s.version     = SkyJam::VERSION
  s.authors     = ['Loic Nageleisen']
  s.email       = ['loic.nageleisen@gmail.com']
  s.homepage    = 'https://github.com/lloeki/ruby-skyjam'
  s.summary     = 'Google Music API client'
  s.description = 'Deftly interact with Google Music (a.k.a Skyjam)'

  s.files = Dir['{bin}/*'] +
            Dir['{lib}/**/*'] +
            ['LICENSE', 'Rakefile', 'README.md']
  s.executables << 'skyjam'

  s.add_dependency 'oauth2', '~> 0.9'
  s.add_dependency 'rainbow'
  s.add_development_dependency 'protobuf', '~> 3.0'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rspec', '~> 2.14'
  s.add_development_dependency 'rake', '~> 10.3'
end
