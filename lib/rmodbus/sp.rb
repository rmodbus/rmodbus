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
  module SP
    attr_reader :port, :baud, :data_bits, :stop_bits, :parity, :read_timeout, :t_1_5, :t_3_5
    # Open serial port
    # @param [String] port name serial ports ("/dev/ttyS0" POSIX, "com1" - Windows)
    # @param [Integer] baud rate serial port (default 9600)
    # @param [Hash] opts the options of serial port
    #
    # @option opts [Integer] :data_bits from 5 to 8
    # @option opts [Integer] :stop_bits 1 or 2
    # @option opts [Integer] :parity NONE, EVEN or ODD
    # @option opts [Integer] :read_timeout default 100 ms
    # @return [SerialPort] io serial port
    def open_serial_port(port, baud, opts = {})
      @port, @baud = port, baud

      @data_bits, @stop_bits, @parity, @read_timeout = 8, 1, SerialPort::NONE, 500 #100

      @data_bits = opts[:data_bits] unless opts[:data_bits].nil?
      @stop_bits = opts[:stop_bits] unless opts[:stop_bits].nil?
      @parity = opts[:parity] unless opts[:parity].nil?
      @read_timeout = opts[:read_timeout] unless opts[:read_timeout].nil?
      io = SerialPort.new(@port, @baud, @data_bits, @stop_bits, @parity)
      io.flow_control = SerialPort::NONE
      
      byte_speed=@baud/(@data_bits+@stop_bits+@parity+1 )  #1 start bit
      @t_3_5=1.5/byte_speed#this is modbus serial line protocol t_3.5
      
      #io.fcntl(Fcntl::F_SETFL, io.fcntl(Fcntl::F_GETFL) | Fcntl::O_NONBLOCK) #ensure that writes go immediately
      
      # read any existing data on the buffer, and discard
#      begin
#         io.read_timeout=-1
#         if io_ready?(io)
#           loop do
#             io.readchar  #empty the buffer
#           end
#         end
#      rescue SystemCallError, Errno::EAGAIN, EOFError    
#      end  
      
      io.read_timeout = @read_timeout
      
      #add the t_3_5 timer to the io object so we can do correct select timeouts
      class << io
        attr_accessor :t_3_5
      end
      io.t_3_5=@t_3_5
      
      io
    end
    
#    private
#    #pull this out into a seperate method to allow it to be mocked
#    def io_ready? (io)
#      IO.select([io],nil,nil,@t_3_5)
#    end

  end
end

