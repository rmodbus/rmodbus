###UPCOMING

1. [BREAKING] Servers now support publishing multiple slaves
2. [BREAKING] RTUViaTCPClient/RTUViaTCPSlave are gone. Please just use RTUClient directly
3. [BREAKING] Proxy collections no longer return an array when requesting a single item.
3. Don't time out waiting to read a response that will never come from broadcast commands
4. Don't send responses to broadcast commands as a server
5. Properly function as a server in an environment with multiple RTU slaves
6. Server now supports promiscuous mode to dump the conversation happening between a master and other slaves.
7. Add read/write multiple registers function (server and client)
8. Add mask write register function to server

###2017-03-30 Release 1.3.2

1. Fix Fixnum warning on Ruby 2.4
2. Add extension method to support unpacking 32-bit Int using little-endian order

###2016-10-18 Release 1.3.0

1. Turn the following dependencies optional: serialport, gserver

###2016-09-20 Release 1.2.8

1. Fix warning on ruby 2.3 when calling Timeout.timeout

###2015-07-30 Release 1.2.7

1. RTUServer doesn't stop serving when there is no RTU messages. Pull request [#37](https://github.com/flipback/rmodbus/pull/37).
2. Fixed a bug with flushing buffer in RTUviaTCPClient.
3. Added validation for UDI in TCPServer. See request [#38](https://github.com/flipback/rmodbus/pull/38).
4. Added a warning message to ask use UID=255 for TCP Server  according to the protocol specification.

###2015-03-21 Release 1.2.6

1. Fixed issue [#35](https://github.com/flipback/rmodbus/issues/35).

###2015-03-12 Release 1.2.5

1. Fixed issue [#34](https://github.com/flipback/rmodbus/issues/34).

###2015-01-29 Release 1.2.4

1. Added ruby-2.2 compatibility

###2015-01-29 Release 1.2.3

1. Fixed bug [#30](https://github.com/flipback/rmodbus/pull/30) in parsing command 'write_register' for server implementation part.

###2013-10-28 Release 1.2.2

1. Fixed issue [#29](https://github.com/flipback/rmodbus/pull/29). The server part supports 2000 of coils/discrete inputs for reading instead of 125.

###2013-06-28 Release 1.2.1

1. Fixed issue [#27](https://github.com/flipback/rmodbus/issues/27) for read_nonblock error on Windows

###2013-03-12 Release 1.2.0

1. Transaction number mismatch doesn't throw exception in TCPSlave#query method.
Now this method will wait correct transaction until timeout breaks waiting.  
2. Added ruby-2.0 experimental compatibility

###2012-07-17 Release 1.1.5

1. Fixed issue [#24](https://github.com/flipback/rmodbus/issues/24) for RTUClient.

###2012-06-28 Release 1.1.4

1. Fixed issue [#23](https://github.com/flipback/rmodbus/issues/23).
2. Improved speed of the RTU\RTUViaTCP part.

###2012-06-06 Release 1.1.3

1. Fixed issue [#22](https://github.com/flipback/rmodbus/issues/22)

###2012-05-12 Release 1.1.2

1. Fixed issue [#20](https://github.com/flipback/rmodbus/issues/20)

###2012-04-12 Release 1.1.1

1. Fixed issue [#15](https://github.com/flipback/rmodbus/issues/15)

2011-10-29 Release 1.1.0
===================================
1. Fixed issue [#12](https://github.com/flipback/rmodbus/issues/12). Added option Slave#raise_exception_on_mismatch to turn to check response and raise exception
   if it's mismatch.
2. Added pass options :debug, :raise_exception_on_mismatch, :read_retry_timeout, :read_retries from clients to slaves

  ```ruby
    @cl.debug = true

    @cl.with_slave(1) do |slave_1|
      slave_1.debug #=> true
    end

    @cl.with_slave(2) do |slave_2|
      slave_2.debug = false
      slave_2.debug #=> false
    end
  ```

3. Deleted dependency with `serialport` gem. Install it manual for using RTU

###2011-08-10 Release 1.0.4

1. Fixed issue [#11](https://github.com/flipback/rmodbus/issues/11)


###2011-07-17 Release 1.0.3

1. Fixed issue #10
2. Added new options for TCPServer#new and RTUViaTCPServer#new
   :host - ip of host server (default 127.0.0.1)
   :max_connection - maximum (client default 4)

###2011-07-1 Release 1.0.2

1. Fixed issue #9

###2011-06-30 Release 1.0.1

1. Fixed issue #8

2011-06-27 Release 1.0.0
=====================================
New API for client part of library
---------------------------------------

Example:

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

for more information [see](http://rdoc.info/gems/rmodbus/1.0.0/frames)

Conversion to/from 32bit registers
-----------------------------------

Some modbus devices use two registers to store 32bit values.
RModbus provides some helper functions to go back and forth between these two things when reading/writing.
The built-in examples assume registers in a particular order but it's trivial to change.

  ```ruby
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
  ```

Support JRuby
--------------------------------------
Now you could use RModBus on JRuby without RTU implementation.

RTU classes requires gem [serialport](https://github.com/hparra/ruby-serialport) which
currently not compatible with JRuby
