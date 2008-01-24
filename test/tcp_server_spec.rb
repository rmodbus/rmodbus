$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'lib/rmodbus'

describe TCPServer do
  
  before do
    @server = ModBus::TCPServer.new(8502)
    @server.start
    @client = ModBus::TCPClient.new('127.0.0.1', 8502, 1)
  end

  it "" do
    @server.coils = [1,0,1,1] 
    @client.read_coils(1,3).should == [0,1,1]
  end

end
