# frozen_string_literal: true

require_relative "lib/rmodbus/version"

Gem::Specification.new do |gem|
  gem.name = "rmodbus-ccutrer"
  gem.version = ModBus::VERSION
  gem.license = "BSD-3-Clause"
  gem.author  = "A.Timin, J. Sanders, K. Reynolds, F. Luizão, C. Cutrer"
  gem.email = "atimin@gmail.com"
  gem.homepage = "https://github.com/ccutrer/rmodbus"
  gem.summary = "RModBus - free implementation of protocol ModBus"
  gem.files = Dir["lib/**/*.rb", "examples/*.rb", "spec/*.rb", "Rakefile"]
  gem.rdoc_options = ["--title", "RModBus", "--inline-source", "--main", "README.md"]
  gem.extra_rdoc_files = ["README.md", "NEWS.md"]
  gem.metadata["rubygems_mfa_required"] = "true"

  gem.required_ruby_version = ">= 2.5"

  gem.add_development_dependency "bundler", "~> 2.2"
  gem.add_development_dependency "ccutrer-serialport", "~> 1.0.0"
  gem.add_development_dependency "gserver", "~> 0.0"
  gem.add_development_dependency "rake", "~> 13.0"
  gem.add_development_dependency "rspec", "~> 3.11"
  gem.add_development_dependency "rubocop", "~> 1.26"
  gem.add_development_dependency "rubocop-performance", "~> 1.12"
  gem.add_development_dependency "rubocop-rake", "~> 0.6"

  gem.add_dependency "digest-crc", "~> 0.1"
end
