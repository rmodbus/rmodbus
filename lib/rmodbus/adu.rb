# RModBus - free implementation of ModBus protocol on Ruby.
#
# Copyright (C) 2008  Timin Aleksey
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
  
    class ADU
      
      @@transaction_id = 0

      attr_reader :unit_id, :transaction_id, :pdu, :size

      def initialize(pdu, uid)
        @pdu = pdu
        @size = pdu.size + 1
        @unit_id = uid
        @transaction_id = @@transaction_id
        @@transaction_id += 1
      end

      def serialize
        @transaction_id.to_bytes + "\x00\x00" + @size.to_bytes + @unit_id.chr + pdu
      end

    end

end
