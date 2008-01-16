begin 
  require 'rubygems'
rescue
end
require 'rmodbus'

include ModBus

class MyTCPClient < TCPClient

  def user_define_function(arg1, arg2)
    query("\x65" + arg1.to_bytes + arg2.to_bytes)
  end

end

@my_mb = MyTCPClient.new('127.0.0.1', 502, 1)
@my_mb.user_define_function(20,13)

