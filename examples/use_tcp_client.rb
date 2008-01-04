require 'rmodbus'

mb = ModBus::TCPClient.new('127.0.0.1', 502, 1)

puts mb.read_holding_registers(100,20)
puts mb.read_coils(21,4)

coils = [1,0,1,1,0,0,1,1]
mb.write_multiple_coils(0,coils)
regs = [0x21, 0x43, 123]
mb.write_multiple_regiters(10, regs) 


