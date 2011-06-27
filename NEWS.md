Release 1.0.0
=====================================
New API for client part of library
---------------------------------------

Example:

    require 'rmodbus'

    ModBus::TCPClient.new('127.0.0.1', 8502) do |cl|
      cl.with_slave(1) do |slave|
        # Read a single holding register at address 16
        slave.holding_registers[16]

        # Write a single holding register at address 16
        slave.holding_registers[16] = 123

        # Read holding registers 16 through 20
        slave.holding_registers[16..20]

        # Write holding registers 16 through 20 with some values
        slave.holding_registers[16..20] = [1, 2, 3, 4, 5]
      end
    end

for more information [see](http://rdoc.info/gems/rmodbus/1.0.0/frames)

Conversion to/from 32bit registers
-----------------------------------

Some modbus devices use two registers to store 32bit values.
RModbus provides some helper functions to go back and forth between these two things when reading/writing.
The built-in examples assume registers in a particular order but it's trivial to change.

    # Reading values in multiple registers (you can read more than 2 and convert them all so long as they are in multiples of 2)
    res = slave.holding_registers[0..1]
    res.inspect => [20342, 17344]
    res.to_32i => [1136676726]
    res.to_32f => [384.620788574219]

    # Writing 32b values to multiple registers
    cl.holding_registers[0..1] = [1136676726].from_32i
    cl.holding_registers[0..1] => [20342, 17344]
    cl.holding_registers[2..3] = [384.620788574219].from_32f
    cl.holding_registers[2..3] => [20342, 17344]

Support JRuby
--------------------------------------
Now you could use RModBus on JRuby without RTU implementation.

RTU classes requires gem [serialport](https://github.com/hparra/ruby-serialport) which
currently not compatible with JRuby
