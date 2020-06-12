module ModBus
  # RTU server implementation
  # @example
  #   srv = RTUServer.new('/dev/ttyS1', 9600)
  #   slave = srv.with_slave(1)
  #   slave.coils = [1,0,1,1]
  #   slave.discrete_inputs = [1,1,0,0]
  #   slave.holding_registers = [1,2,3,4]
  #   slave.input_registers = [1,2,3,4]
  #   srv.debug = true
  #   srv.start
  class RTUServer
    include Debug
    include Server
    include RTU
    include SP

    # Init RTU server
    # @param [Integer] uid slave device
    # @see SP#open_serial_port
    def initialize(port, baud=9600, opts = {})
      Thread.abort_on_exception = true
      if port.is_a?(IO) || port.respond_to?(:read)
        @sp = port
      else
        @sp = open_serial_port(port, baud, opts)
      end
    end

    # Start server
    def start
      @serv = Thread.new do
        serve(@sp)
      end
    end

    # Stop server
    def stop
      Thread.kill(@serv)
      @sp.close
    end

    # Join server
    def join
      @serv.join
    end
  end
end
