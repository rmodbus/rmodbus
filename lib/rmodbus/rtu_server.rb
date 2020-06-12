module ModBus
  # RTU server implementation
  # @example
  #   srv = RTUServer.new('/dev/ttyS1', 9600, 1)
  #   srv.coils = [1,0,1,1]
  #   srv.discrete_inputs = [1,1,0,0]
  #   srv.holding_registers = [1,2,3,4]
  #   srv.input_registers = [1,2,3,4]
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
    def initialize(port, baud=9600, uid=1, opts = {})
      Thread.abort_on_exception = true
      @sp = open_serial_port(port, baud, opts)
      @uid = uid
    end

    # Start server
    def start
      @serv = Thread.new do
        serv_rtu_requests(@sp) do |msg|
          exec_req(msg[1..-3])
        end
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
