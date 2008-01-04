require 'socket'
require 'timeout'
require 'rmodbus/client'
require 'rmodbus/exceptions'
require 'rmodbus/adu'

module ModBus

  class TCPClient < Client

    include Timeout

    def initialize(ipaddr, port = 502, slaveaddr = 1)
      timeout(1) do
        @sock = TCPSocket.new(ipaddr, port)
      end
      @slave = slaveaddr.chr
    end

 
    private
    def send_pdu(pdu)   
      @sock.write ADU.new(pdu,@slave).serialize
    end

    def read_pdu     
      header = @sock.read(7)            
      tin = header[0,2].to_int16
      raise Errors::ModBusException.new "Transaction number mismatch" unless tin == @@transaction_no
      len = header[4,2].to_int16       
      @sock.read(len-1)               
    end

  end

end
