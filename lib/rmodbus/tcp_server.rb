begin
  require 'gserver'
rescue
  warn "[WARNING] Install `gserver` gem for use TCPServer"
end

module ModBus
  # TCP server implementation
  # @example
  #   srv = TCPServer.new(10002)
  #   slave = srv.with_slave(255)
  #   slave.coils = [1,0,1,1]
  #   slave.discrete_inputs = [1,1,0,0]
  #   slave.holding_registers = [1,2,3,4]
  #   slave.input_registers = [1,2,3,4]
  #   srv.debug = true
  #   srv.start
	class TCPServer < GServer
		include Debug
		include Server

    # Init server
    # @param [Integer] port listen port
    # @param [Integer] uid slave device
    # @param [Hash] opts options of server
    # @option opts [String] :host host of server default '127.0.0.1'
    # @option opts [Float, Integer] :max_connection max of TCP connection with server default 4
		def initialize(port = 502, opts = {})
      opts[:host] = DEFAULT_HOST unless opts[:host]
      opts[:max_connection] = 4 unless opts[:max_connection]
			super(port, host = opts[:host], maxConnection = opts[:max_connection])
		end

    # set the default param
    def with_slave(uid = 255)
      super
    end

    # Serve requests
    # @param [TCPSocket] io socket
    def serve(io)
      while not stopped?
        header = io.read(7)
        tx_id = header[0,2]
        proto_id = header[2,2]
        len = header[4,2].unpack('n')[0]
        unit_id = header.getbyte(6)
        if proto_id == "\x00\x00"
          req = io.read(len - 1)
          log "Server RX (#{req.size} bytes): #{logging_bytes(req)}"

          func = req.getbyte(0)
          params = parse_request(func, req)
          pdu = exec_req(unit_id, func, params, req)

          if pdu
            resp = tx_id + "\0\0" + (pdu.size + 1).to_word + unit_id.chr + pdu
            log "Server TX (#{resp.size} bytes): #{logging_bytes(resp)}"
            io.write resp
          else
            log "Ignored server RX (invalid unit ID #{unit_id}, #{req.size} bytes): #{logging_bytes(req)}"
          end
        end
      end
    end
	end
end
