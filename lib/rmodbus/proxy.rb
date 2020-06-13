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
      if key.instance_of?(0.class)
        @slave.send("read_#{@type}", key)
      elsif key.instance_of?(Range)
        @slave.send("read_#{@type}s", key.first, key.count)
      else
        raise ModBus::Errors::ProxyException, "Invalid argument, must be integer or range. Was #{key.class}"
      end
    end
  end

  class ReadWriteProxy < ReadOnlyProxy
    # Write single or multiple values to a modbus slave depending on whether a Fixnum or a Range was given.
    # Note that in the case of multiples, a pluralized version of the method is sent to the slave. Also when
    # writing multiple values, the number of elements must match the number of registers in the range or an exception is raised
    def []=(key, val)
      if key.instance_of?(0.class)
        @slave.send("write_#{@type}", key, val)
      elsif key.instance_of?(Range)
        if key.count != val.size
          raise ModBus::Errors::ProxyException, "The size of the range must match the size of the values (#{key.count} != #{val.size})"
        end

        @slave.send("write_#{@type}s", key.first, val)
      else
        raise ModBus::Errors::ProxyException, "Invalid argument, must be integer or range. Was #{key.class}"
      end
    end
  end

end
