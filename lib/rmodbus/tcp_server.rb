require 'lib/rmodbus/exceptions'
require 'gserver'


module ModBus
	
	class TCPServer < GServer
    
    attr_accessor :coils
    
    def initialize(port = 502, uid = 1)
      @coils = []
      super(port)
    end

    def serve(io)
      req = io.gets
      resp = req[0,1] + "\0\0"
      io.print resp
    end

	end
	
end
