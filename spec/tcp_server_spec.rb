require 'lib/rmodbus'

describe TCPServer do
  
  before do
    @server = ModBus::TCPServer.new(8502,1)
    @server.coils = [1,0,1,1]
    @server.discrete_inputs = [1,1,0,0]
    @server.holding_registers = [1,2,3,4]
    @server.input_registers = [1,2,3,4]
    @server.start
    @cl = ModBus::TCPClient.new('127.0.0.1', 8502)
    @slave = @cl.with_slave(1)
    @slave.read_retries = 0
  end

  it "should silent if UID has mismatched" do
    @cl.close
    ModBus::TCPClient.connect('127.0.0.1', 8502) do |cl|
      lambda { cl.with_slave(2).read_coils(1,3) }.should raise_exception(
        ModBus::Errors::ModBusException, 
        "Server did not respond"
      )
    end
  end

  it "should send exception if function not supported" do
    lambda { @slave.query('0x43') }.should raise_exception(
      ModBus::Errors::IllegalFunction,
      "The function code received in the query is not an allowable action for the server" 
    )
  end

  it "should send exception if quanity of out more 0x7d" do
    lambda { @slave.read_coils(0, 0x7e) }.should raise_exception(
      ModBus::Errors::IllegalDataValue, 
      "A value contained in the query data field is not an allowable value for server"
    )
  end

  it "should send exception if addr not valid" do
    lambda { @slave.read_coils(2, 8) }.should raise_exception(
      ModBus::Errors::IllegalDataAddress, 
      "The data address received in the query is not an allowable address for the server"
    )
  end

  it "should calc a many requests" do
    @slave.read_coils(1,2)
    @slave.write_multiple_registers(0,[9,9,9,])
    @slave.read_holding_registers(0,3).should == [9,9,9]
  end

  it "should supported function 'read coils'" do
    @slave.read_coils(0,3).should == @server.coils[0,3]
  end

  it "should supported function 'read discrete inputs'" do
    @slave.read_discrete_inputs(1,3).should == @server.discrete_inputs[1,3]
  end

  it "should supported function 'read holding registers'" do
    @slave.read_holding_registers(0,3).should == @server.holding_registers[0,3]
  end

  it "should supported function 'read input registers'" do
    @slave.read_input_registers(2,2).should == @server.input_registers[2,2]
  end

  it "should supported function 'write single coil'" do
    @server.coils[3] = 0
    @slave.write_single_coil(3,1)
    @server.coils[3].should == 1
  end

  it "should supported function 'write single register'" do
    @server.holding_registers[3] = 25
    @slave.write_single_register(3,35)
    @server.holding_registers[3].should == 35
  end

  it "should supported function 'write multiple coils'" do
    @server.coils = [1,1,1,0, 0,0,0,0, 0,0,0,0, 0,1,1,1]
    @slave.write_multiple_coils(3, [1, 0,1,0,1, 0,1,0,1])
    @server.coils.should == [1,1,1,1, 0,1,0,1, 0,1,0,1, 0,1,1,1]
  end

  it "should supported function 'write multiple registers'" do
    @server.holding_registers = [1,2,3,4,5,6,7,8,9]
    @slave.write_multiple_registers(3,[1,2,3,4,5])
    @server.holding_registers.should == [1,2,3,1,2,3,4,5,9]
  end

  after do
    @cl.close 
    @server.stop unless @server.stopped?
    while GServer.in_service?(8502) 
    end
  end
end
