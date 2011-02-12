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

  end

end
