require 'rubygems'
spec = Gem::Specification.new do |s|
	s.name = "RModBus"
	s.version = "0.0.1"
	s.author  = 'A.Timin'
	s.platform = Gem::Platform::RUBY
	s.summary = "A lib for the RModBus"
	s.files = Dir['lib/**/*.rb']
 	s.require_path = "lib"
 	s.autorequire = "rmodbus"
 	s.test_file = "../../test/client_spec.rb"
 	s.has_rdoc = false
 	s.add_dependency("BlueCloth",">=0.0.4")
end
