require 'rubygems'
spec = Gem::Specification.new do |s|
	s.name = "rmodbus"
	s.version = "0.3.0"
	s.author  = 'A.Timin, J. Sanders'
	s.platform = Gem::Platform::RUBY
	s.summary = "RModBus - free implementation of protocol ModBus"
	s.files = Dir['lib/**/*.rb','examples/*.rb','spec/*.rb','doc/*/*']
 	s.autorequire = "rmodbus"
 	s.has_rdoc = true
  s.rdoc_options = ["--title", "RModBus", "--inline-source", "--main", "README"]
  s.extra_rdoc_files = ["README", "AUTHORS", "LICENSE", "CHANGES"]
end
