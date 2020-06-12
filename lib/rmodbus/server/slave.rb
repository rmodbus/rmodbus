require 'timeout'

module ModBus
  module Server
    class Slave
      attr_accessor :coils, :discrete_inputs, :holding_registers, :input_registers

      def initialize
        @coils = []
        @discrete_inputs = []
        @holding_registers =[]
        @input_registers = []
      end
    end
  end
end
