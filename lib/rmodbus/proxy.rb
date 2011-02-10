# ReadOnly and ReadWrite hash interface for modbus registers and coils
#
# Copyright (C) 2010  Kelley Reynolds
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
module ModBus
  # Given a slave and a type of operation, execute a single or multiple read using hash syntax
  class ReadOnlyProxy
    # Initialize a proxy for a slave and a type of operation
    def initialize(slave, type)
      @slave, @type = slave, type
    end

    # Read single or multiple values from a modbus slave depending on whether a Fixnum or a Range was given.
    # Note that in the case of multiples, a pluralized version of the method is sent to the slave
    def [](key)
      if key.instance_of?(Fixnum)
        @slave.send("read_#{@type}", key, 1)
      elsif key.instance_of?(Range)
        @slave.send("read_#{@type}s", key.first, key.count)
      else
        raise ProxyException, "Invalid argument, must be integer or range. Was #{key.class}"
      end
    end
  end
  
  class ReadWriteProxy < ReadOnlyProxy
    # Write single or multiple values to a modbus slave depending on whether a Fixnum or a Range was given.
    # Note that in the case of multiples, a pluralized version of the method is sent to the slave. Also when
    # writing multiple values, the number of elements must match the number of registers in the range or an exception is raised
    def []=(key, val)
      if key.instance_of?(Fixnum)
        @slave.send("write_#{@type}", key, val)
      elsif key.instance_of?(Range)
        if key.count != val.size
          raise ProxyException, "The size of the range must match the size of the values (#{key.count} != #{val.size})"
        end

        @slave.send("write_#{@type}s", key.first, val)
      else
        raise ProxyException, "Invalid argument, must be integer or range. Was #{key.class}"
      end
    end
  end

end