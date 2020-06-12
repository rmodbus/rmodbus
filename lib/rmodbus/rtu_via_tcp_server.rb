begin
  require 'gserver'
rescue
  warn "[WARNING] Install `gserver` gem for use RTUViaTCPServer"
end

module ModBus
  # RTU over TCP server implementation
  # @example
  #   srv = RTUViaTCPServer.new(10002, 1)
  #   srv.coils = [1,0,1,1]
  #   srv.discrete_inputs = [1,1,0,0]
  #   srv.holding_registers = [1,2,3,4]
  #   srv.input_registers = [1,2,3,4]
  #   srv.debug = true
  #   srv.start
  class RTUViaTCPServer < GServer
    include Debug
    include RTU
    include Server

    # Init server
    # @param [Integer] port listen port
    # @param [Integer] uid slave device
    # @param [Hash] opts options of server
    # @option opts [String] :host host of server default '127.0.0.1'
    # @option opts [Float, Integer] :max_connection max of TCP connection with server default 4
    def initialize(port = 10002, uid = 1, opts = {})
			@uid = uid
      opts[:host] = DEFAULT_HOST unless opts[:host]
      opts[:max_connection] = 4 unless opts[:max_connection]
			super(port, host = opts[:host], maxConnection = opts[:max_connection])
		end

    protected
    # Serve requests
    # @param [TCPSocket] io socket
    def serve(io)
      serv_rtu_requests(io) do |msg|
        exec_req(msg[1..-3])
      end
    end
  end
end
