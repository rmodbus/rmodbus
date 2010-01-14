$:.unshift(File.dirname(__FILE__) + '/../lib/')
require 'rmodbus'

srv = ModBus::TCPServer.new(8502,1)
srv.coils = [1,0,1,1]
srv.discret_inputs = [1,1,0,0]
srv.holding_registers = [1,2,3,4]
srv.input_registers = [1,2,3,4]
srv.debug = true
srv.audit = true
srv.start

cl = ModBus::TCPClient.new('127.0.0.1', 8502, 1)
cl.debug = true
puts cl.read_holding_registers(0,4)
cl.write_multiple_registers(0, [4,4,4])
puts cl.read_holding_registers(0,4)
srv.stop
