# RModBus - free implementation of ModBus protocol in Ruby.
#
# Copyright (C) 2010  Timin Aleksey
# Copyright (C) 2010  Kelley Reynolds
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

require 'gserver'

module ModBus
  class RTUViaTCPServer < GServer
    include Common
    include RTU 
    include Server 
    
    def initialize(port = 10002, uid = 1)
      @uid = uid
      super(port)
    end

    def serve(io)
      serv_rtu_requests(io) do |msg|
        exec_req(msg[1..-3], @coils, @discrete_inputs, @holding_registers, @input_registers)
      end
    end
  end
end
