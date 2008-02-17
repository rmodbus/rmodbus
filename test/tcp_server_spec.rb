$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'lib/rmodbus'

describe TCPServer do
  
  before do
    @server = ModBus::TCPServer.new(8502,1)
    @server.coils = [1,0,1,1]
    @server.start
    @client = ModBus::TCPClient.new('127.0.0.1', 8502, 1)
  end

  it "should silent if UID has mismatched" do
    @client.close
    client = ModBus::TCPClient.new('127.0.0.1', 8502, 2)
    begin
      client.read_coils(1,3)
    rescue ModBus::Errors::ModBusException => ex
      ex.message.should == "Server not respond"
    end
  end

  it "should silent if protocol identifer has mismatched" do
    client = TCPSocket.new('127.0.0.1', 8502)
    begin
      client.write "\0\0\1\0\0\6\1"
    rescue ModBus::Errors::ModBusException => ex
      ex.message.should == "Server not respond"
    end
  end

  it "should send exception if function not supported" do
    begin 
      @client.query([0x43]) 
    rescue ModBus::Errors::IllegalFunction => ex
      ex.message.should == "The function code received in the query is not an allowable action for the server"  
    end 
  end

  it "should send exception if quanity of out more 0x7d" do
    begin
      @client.read_coils(0, 0x7e)
    rescue ModBus::Errors::IllegalDataValue => ex
      ex.message.should == "A value contained in the query data field is not an allowable value for server"
    end
  end

  it "should send exception if addr not valid" do
    begin
      @client.read_coils(2, 8)
    rescue ModBus::Errors::IllegalDataAddress => ex
      ex.message.should == "The data address received in the query is not an allowable address for the server"
    end
  end

  it "should send valid date" do
    @client.read_coils(0,3).should == @server.coils[0,3]
  end

  after do
    @server.stop
  end

end
