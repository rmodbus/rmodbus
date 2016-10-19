module ModBus
  module Errors
    class ProxyException < StandardError
    end

    class ModBusException < StandardError
    end

    class IllegalFunction < ModBusException
    end

    class IllegalDataAddress < ModBusException
    end

    class IllegalDataValue < ModBusException
    end

    class SlaveDeviceFailure < ModBusException
    end

    class Acknowledge < ModBusException
    end

    class SlaveDeviceBus < ModBusException
    end

    class MemoryParityError < ModBusException
    end

    class ModBusTimeout < ModBusException
    end

    class ResponseMismatch < ModBusException
      attr_reader :request, :response
      def initialize(msg, request, response)
        super(msg)
        @request = request
        @response = response
      end
    end
  end
end
