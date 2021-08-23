lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rmodbus/version'

Gem::Specification.new do |gem|
  gem.name = "rmodbus-ccutrer"
  gem.version = ModBus::VERSION
  gem.license = 'BSD-3-Clause'
  gem.author  = 'A.Timin, J. Sanders, K. Reynolds, F. Luizão, C. Cutrer'
  gem.email = "atimin@gmail.com"
  gem.homepage = "https://github.com/ccutrer/rmodbus"
  gem.summary = "RModBus - free implementation of protocol ModBus"
  gem.files = Dir['lib/**/*.rb','examples/*.rb','spec/*.rb', 'Rakefile']
  gem.rdoc_options = ["--title", "RModBus", "--inline-source", "--main", "README.md"]
  gem.extra_rdoc_files = ["README.md", "NEWS.md"]

  gem.add_development_dependency 'rake','>= 12.3.3'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rspec', '~> 2.99'
  gem.add_development_dependency 'guard-rspec', '~> 1.2'
  gem.add_development_dependency 'pry', '~> 0.10'
  gem.add_development_dependency 'serialport', '~> 1.3'
  gem.add_development_dependency 'gserver', '~> 0.0'

  gem.add_dependency 'digest-crc', '~> 0.1'
end
