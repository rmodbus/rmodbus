module ModBus
  module Errors
    class ProxyException < RuntimeError
    end

    class ModBusException < RuntimeError
    end

    class IllegalFunction < ModBusException
      def initialize(msg = nil)
        super(msg || "The function code received in the query is not an allowable action for the server")
      end
    end

    class IllegalDataAddress < ModBusException
      def initialize
        super("The data address received in the query is not an allowable address for the server")
      end
    end

    class IllegalDataValue < ModBusException
      def initialize
        super("A value contained in the query data field is not an allowable value for server")
      end
    end

    class SlaveDeviceFailure < ModBusException
      def initialize
        super("An unrecoverable error occurred while the server was attempting to perform the requested action")
      end
    end

    class Acknowledge < ModBusException
      def initialize
        super("The server has accepted the request and is processing it, but a long duration of time will be required to do so") # rubocop:disable Layout/LineLength
      end
    end

    class SlaveDeviceBus < ModBusException
      def initialize
        super("The server is engaged in processing a long duration program command")
      end
    end

    class MemoryParityError < ModBusException
      def initialize
        super("The extended file area failed to pass a consistency check")
      end
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
