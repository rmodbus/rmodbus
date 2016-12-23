RModBus [![Build Status](https://secure.travis-ci.org/rmodbus/rmodbus.png)](http://travis-ci.org/rmodbus/rmodbus) [![Gem Version](https://badge.fury.io/rb/rmodbus.svg)](http://badge.fury.io/rb/rmodbus)
==========================

**RModBus** - free implementation of ModBus protocol in pure Ruby.

Features
---------------------------
  - Ruby 2.2, 2.3 and JRuby (without serial ModBus RTU)
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

Or if you are using bundler, add to your Gemfile:

```
gem 'rmodbus'
```

If you want to use ModBus over serial, you will also need to install the 'serialport' gem.
If you are using bundler, add to your Gemfile:

```
gem 'serialport'
```

If you want to use ModBus::TCPServer or ModBus::RTUViaTCPServer and are using Ruby >= 2.2,
you will also need to install the 'gserver' gem. If you are using bundler, add to your Gemfile:

```
gem 'gserver'
```

Please note that GServer is deprecated, and I'm looking for a better solution.
Contributions are welcome!

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

Versioning
----------------------------------

This project will follow http://semver.org/

```
Given a version number MAJOR.MINOR.PATCH, increment the:

MAJOR version when you make incompatible API changes,
MINOR version when you add functionality in a backwards-compatible manner, and
PATCH version when you make backwards-compatible bug fixes.
```

Contributing
----------------------------------

See [CONTRIBUTING](CONTRIBUTING.md).

Reference
----------------------------------

RModBus on GitHub: http://github.com/rmodbus/rmodbus

Documentation: http://www.rubydoc.info/github/rmodbus/rmodbus

ModBus specifications: http://www.modbus.org/specs.php

License
----------------------------------

BSD-3-Clause

Credits
----------------------------------

Aleksey Timin - original author
