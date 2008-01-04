module ModBus

  module Errors

    class ModBusException < Exception
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

    class SlaveDiviceBus < ModBusException
    end

    class MemoryParityError < ModBusException
    end

  end

end
