RModBus
==========================

**RModBus** - free implementation of protocol ModBus.

Features
---------------------------
  - Ruby 1.8, Ruby 1.9, JRuby (without serial ModBus RTU)
  - TCP, RTU, RTU over TCP protocols
  - Client(master) and server(slave)
  - 16, 32 -bit and float registers

Support functions
---------------------------
  * Read Coils (0x01)
  * Read Discrete Inputs (0x02)
  * Read Holding Registers (0x03)
  * Read Input Registers (0x04)
  * Write Single Coil (0x05)
  * Write Single Register (0x06)
  * Write Multiple Coils (0x0F)
  * Write Multiple registers (0x10)
  * Mask Write register (0x16)

Installation
------------------------------------

Download and install RModBus with the following

**$ gem install rmodbus**

Example
------------------------------------

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

GitHub
----------------------------------

You can checkout source code from GitHub repositry

**$ git clone git://github.com/flipback/RModBus.git**

Reference
----------------------------------

Home page: http://rmodbus.flipback.net

RModBud on GitHub: http://github.com/flipback/RModBus

ModBus community: http://www.modbus-ida.org
