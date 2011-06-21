$:.unshift(File.dirname(__FILE__) + '/../lib/')
require 'rmodbus'

srv = ModBus::TCPServer.new(8502,1)
srv.coils = [1,0,1,1]
srv.discrete_inputs = [1,1,0,0]
srv.holding_registers = [1,2,3,4]
srv.input_registers = [1,2,3,4]
srv.debug = true
srv.audit = true
srv.start

ModBus::TCPClient.connect('127.0.0.1', 8502) do |cl|
  cl.with_slave(1) do |slave|
    slave.debug = true
    regs = slave.holding_registers
  	puts regs[0..3]
  	regs[0..3] = [2,0,1,1]
  	puts regs[0..3]
  end
end

srv.stop
