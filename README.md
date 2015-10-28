RModBus [![Build Status](https://secure.travis-ci.org/flipback/rmodbus.png)](http://travis-ci.org/flipback/rmodbus) [![Gem Version](https://badge.fury.io/rb/rmodbus.svg)](http://badge.fury.io/rb/rmodbus)
==========================

**RModBus** - free implementation of ModBus protocol in pure Ruby.

Features
---------------------------
  - Ruby 2.1, 2.2 and JRuby (without serial ModBus RTU)
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

Download and install RModBus with the following:

```
gem install rmodbus
```

Example
------------------------------------

  ```ruby
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
  ```

GitHub
----------------------------------

You can checkout source code from GitHub repository:

```
git clone git://github.com/flipback/RModBus.git
```

Reference
----------------------------------

Home page: http://rmodbus.flipback.net

RModBus on GitHub: http://github.com/flipback/RModBus

ModBus specifications: http://www.modbus.org/specs.php
