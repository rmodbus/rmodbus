lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rmodbus/version'

Gem::Specification.new do |gem|
  gem.name = "rmodbus"
  gem.version = ModBus::VERSION
  gem.author  = 'A.Timin, J. Sanders, K. Reynolds'
  gem.email = "atimin@gmail.com"
  gem.homepage = "http://rmodbus.heroku.com"
  gem.summary = "RModBus - free implementation of protocol ModBus"
  gem.files = Dir['lib/**/*.rb','examples/*.rb','spec/*.rb', 'Rakefile']
  gem.rdoc_options = ["--title", "RModBus", "--inline-source", "--main", "README.md"]
  gem.extra_rdoc_files = ["README.md", "AUTHORS", "LICENSE"]

  if RUBY_PLATFORM == 'java'
    gem.platform = Gem::Platform.new("java")
  else
    gem.platform = Gem::Platform::RUBY
    gem.add_dependency 'serialport'
  end

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rcov'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'rdiscount'
end