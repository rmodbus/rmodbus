# RModBus - free implementation of ModBus protocol in Ruby.
#
# Copyright (C) 2011  Timin Aleksey
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
  class RTUSlave < Slave 
    include RTU 

    def initialize(uid, sp)
      @sp = sp
      super(uid)
    end

    protected
    def send_pdu(pdu)
      msg = @uid.chr + pdu 
      msg << crc16(msg).to_word
      @sp.write msg

      log "Tx (#{msg.size} bytes): " + logging_bytes(msg)
    end

    def read_pdu
	  msg = read_rtu_response(@sp)

      log "Rx (#{msg.size} bytes): " + logging_bytes(msg)

      if msg.getbyte(0) == @uid
        return msg[1..-3] if msg[-2,2].unpack('n')[0] == crc16(msg[0..-3])
        log "Ignore package: don't match CRC"
      else 
        log "Ignore package: don't match uid ID"
      end
      loop do
        #waite timeout  
      end
    end
  end
end
