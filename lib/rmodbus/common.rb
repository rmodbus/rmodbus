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

module ModBus
  module Common
   attr_accessor :debug

   @debug = false
   private
   def log(msg)
     $stdout.puts msg if @debug
   end

   def logging_bytes(msg)
     result = ""
     msg.each_byte do |c|
       byte = if c < 16
         '0' + c.to_s(16)
       else
          c.to_s(16)
       end
         result << "[#{byte}]"
      end
      result
    end
  end
end

