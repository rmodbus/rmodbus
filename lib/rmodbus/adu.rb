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
