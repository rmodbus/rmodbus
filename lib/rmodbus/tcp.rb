require 'socket'

module ModBus
  module TCP
    include Errors
    attr_reader :ipaddr, :port

    # Open TCP socket
    #
    # @param [String] ipaddr IP address of remote server
    # @param [Integer] port connection port
    # @param [Hash] opts options of connection
    # @option opts [Float, Integer] :connect_timeout seconds timeout for open socket
    # @return [Socket] socket
    #
    # @raise [ModBusTimeout] timed out attempting to create connection
    def open_tcp_connection(ipaddr, port, opts = {})
      @ipaddr, @port = ipaddr, port

      timeout = opts[:connect_timeout] ||= 1

      io = nil
      begin
        io = Socket.tcp(@ipaddr, @port, nil, nil, connect_timeout: timeout)
      rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT
        raise ModBusTimeout.new, 'Timed out attempting to create connection'
      end

      io
    end
  end
end
