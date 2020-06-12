# -*- coding: ascii
require "rmodbus"

describe ModBus::RTUViaTCPServer do
  before :all do
    @port = 8502
    begin
      @server = ModBus::RTUViaTCPServer.new(@port)
      @server_slave = @server.with_slave(1)
      @server_slave.coils = [1,0,1,1]
      @server_slave.discrete_inputs = [1,1,0,0]
      @server_slave.holding_registers = [1,2,3,4]
      @server_slave.input_registers = [1,2,3,4]
      @server.start
    rescue Errno::EADDRINUSE
      @port += 1
      retry
    end
    @cl = ModBus::RTUClient.new('127.0.0.1', @port)
    @cl.read_retries = 1
    @slave = @cl.with_slave(1)
    # pretend this is a serialport and we're just someone else on the same bus
    @io = @cl.instance_variable_get(:@io)
  end

  it "should have options :host" do
    host = '192.168.0.1'
    srv = ModBus::RTUViaTCPServer.new(1010, :host => '192.168.0.1')
    srv.host.should eql(host)
  end

  it "should have options :max_connection" do
    max_conn = 5
    srv = ModBus::RTUViaTCPServer.new(1010, :max_connection => 5)
    srv.maxConnections.should eql(max_conn)
  end

  it "should send exception if function not supported" do
    lambda { @slave.query('0x43') }.should raise_exception(
                                               ModBus::Errors::IllegalFunction,
                                               "The function code received in the query is not an allowable action for the server"
                                           )
  end

  it "should properly ignore responses from other slaves" do
    request = "\x10\x03\x0\x1\x0\x1\x8b\xd6"
    response = "\x10\x83\x1\xf5\xd0"
    @io.write(request)
    @io.write(response)
    # just to prove the server can still handle subsequent requests
    @slave.read_coils(0, 1).should == [1]
  end

  it "should properly ignore functions from other slaves that it doesn't understand" do
    request = "\x10\x41\x0\x1\x0\x1\x0\x5\x0\x1\x00\xb1"
    response = "\x10\xc1\x1\x55\xe0"
    @io.write(request)
    @io.write(response)
    # just to prove the server can still handle subsequent requests
    @slave.read_coils(0, 1).should == [1]
  end

  it "should properly ignore utter garbage on the line from starting up halfway through a conversation" do
    response = "\x1\x55\xe0"
    @io.write(response)
    # just to prove the server can still handle subsequent requests
    @slave.read_coils(0, 1).should == [1]
  end

  after :all do
    @cl.close unless @cl.closed?
    @server.stop unless @server.stopped?
    while GServer.in_service?(@port)
      sleep(0.01)
    end
    @server.stop
  end
end
