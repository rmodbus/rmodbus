$:.unshift(File.dirname(__FILE__) + '/../lib/')
require 'rmodbus'

srv = ModBus::RTUViaTCPServer.new(10002,1)
srv.coils = [1,0,1,1]
srv.discrete_inputs = [1,1,0,0]
srv.holding_registers = [1,2,3,4]
srv.input_registers = [1,2,3,4]
srv.debug = true
srv.start

ModBus::RTUViaTCPClient.connect('127.0.0.1', 10002, 1) do |cl|
	cl.debug = true
	puts cl.read_holding_registers(0,4).inspect
	cl.write_multiple_registers(0, [4,4,4])
	puts cl.read_holding_registers(0,4).inspect
end

srv.shutdown
