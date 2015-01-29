lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rmodbus/version'

Gem::Specification.new do |gem|
  gem.name = "rmodbus"
  gem.version = ModBus::VERSION
  gem.license = 'GPL v2.0'
  gem.author  = 'A.Timin, J. Sanders, K. Reynolds'
  gem.email = "atimin@gmail.com"
  gem.homepage = "http://rmodbus.flipback.net"
  gem.summary = "RModBus - free implementation of protocol ModBus"
  gem.files = Dir['lib/**/*.rb','examples/*.rb','spec/*.rb', 'Rakefile']
  gem.rdoc_options = ["--title", "RModBus", "--inline-source", "--main", "README.md"]
  gem.extra_rdoc_files = ["README.md", "NEWS.md"]

  gem.add_development_dependency 'rake','~>10.4'
  gem.add_development_dependency 'bundler', '~>1.7'
  gem.add_development_dependency 'rspec', '~>2.9'
  gem.add_development_dependency 'guard-rspec', '~>1.2'
  gem.add_development_dependency 'pry', '~>0.10'
  
  unless RUBY_PLATFORM == 'java'
    gem.add_development_dependency 'serialport', '~>1.3'
  end

end
