require 'rubygems'
spec = Gem::Specification.new do |s|
  s.name = "rmodbus"
  s.version = "0.5.0"
  s.author  = 'A.Timin, J. Sanders, K. Reynolds'
  s.email = "atimin@gmail.com"
  s.homepage = "http://rmodbus.heroku.com"
  s.rubyforge_project = "RModBus"
  s.platform = Gem::Platform::RUBY
  s.summary = "RModBus - free implementation of protocol ModBus"
  s.files = Dir['lib/**/*.rb','examples/*.rb','spec/*.rb','doc/*/*', 'Rakefile']
  s.autorequire = "rmodbus"
  s.has_rdoc = true
  s.rdoc_options = ["--title", "RModBus", "--inline-source", "--main", "README"]
  s.extra_rdoc_files = ["README", "AUTHORS", "LICENSE", "ChangeLog"]
  s.add_dependency("serialport", ">=1.0.4")
end
