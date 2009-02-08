require 'lib/rmodbus'

describe TCPServer do
  
  before do
    @server = ModBus::TCPServer.new(8502,1)
    @server.coils = [1,0,1,1]
    @server.discret_inputs = [1,1,0,0]
    @server.holding_registers = [1,2,3,4]
    @server.input_registers = [1,2,3,4]
    @server.start
    @client = ModBus::TCPClient.new('127.0.0.1', 8502, 1)
  end

  it "should silent if UID has mismatched" do
    @client.close
    client = ModBus::TCPClient.new('127.0.0.1', 8502, 2)
    begin
      client.read_coils(1,3)
    rescue ModBus::Errors::ModBusException => ex
      ex.message.should == "Server did not respond"
    end
    client.close
  end

  it "should silent if protocol identifer has mismatched" do
    @client.close
    client = TCPSocket.new('127.0.0.1', 8502)
    begin
      client.write "\0\0\1\0\0\6\1"
    rescue ModBus::Errors::ModBusException => ex
      ex.message.should == "Server did not respond"
    end
    client.close
  end

  it "should send exception if function not supported" do
    begin 
      @client.query('0x43') 
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

  it "should calc a many requests" do
    @client.read_coils(1,2)
    @client.write_multiple_registers(0,[9,9,9,])
    @client.read_holding_registers
  end

  it "should supported function 'read coils'" do
    @client.read_coils(0,3).should == @server.coils[0,3]
  end

  it "should supported function 'read discrete inputs'" do
    @client.read_discrete_inputs(1,3).should == @server.discret_inputs[1,3]
  end

  it "should supported function 'read holding registers'" do
    @client.read_holding_registers(0,3).should == @server.holding_registers[0,3]
  end

  it "should supported function 'read input registers'" do
    @client.read_input_registers(2,2).should == @server.input_registers[2,2]
  end

  it "should supported function 'write single coil'" do
    @server.coils[3] = 0
    @client.write_single_coil(3,1)
    @server.coils[3].should == 1
  end

  it "should supported function 'write single register'" do
    @server.holding_registers[3] = 25
    @client.write_single_register(3,35)
    @server.holding_registers[3].should == 35
  end

  it "should supported function 'write multiple coils'" do
    @server.coils = [1,1,1,0, 0,0,0,0, 0,0,0,0, 0,1,1,1]
    @client.write_multiple_coils(3, [1, 0,1,0,1, 0,1,0,1])
    @server.coils.should == [1,1,1,1, 0,1,0,1, 0,1,0,1, 0,1,1,1]
  end

  it "should supported function 'write multiple registers'" do
    @server.holding_registers = [1,2,3,4,5,6,7,8,9]
    @client.write_multiple_registers(3,[1,2,3,4,5])
    @server.holding_registers.should == [1,2,3,1,2,3,4,5,9]
  end

  after do
    @client.close 
    @server.stop unless @server.stopped?
    while GServer.in_service?(8502) 
    end
  end
end
