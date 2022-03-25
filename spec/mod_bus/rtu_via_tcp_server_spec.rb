# -*- coding: ascii
# frozen_string_literal: true

describe ModBus::RTUViaTCPServer do
  before :all do
    @port = 8502
    begin
      @server = ModBus::RTUViaTCPServer.new(@port)
      @server_slave = @server.with_slave(1)
      @server_slave.coils = [1, 0, 1, 1]
      @server_slave.discrete_inputs = [1, 1, 0, 0]
      @server_slave.holding_registers = [1, 2, 3, 4]
      @server_slave.input_registers = [1, 2, 3, 4]
      @server.promiscuous = true
      @server.start
    rescue Errno::EADDRINUSE
      @port += 1
      retry
    end
    @cl = ModBus::RTUClient.new("127.0.0.1", @port)
    @cl.read_retries = 1
    @slave = @cl.with_slave(1)
    # pretend this is a serialport and we're just someone else on the same bus
    @io = @cl.instance_variable_get(:@io)
  end

  after :all do
    @cl.close unless @cl.closed?
    @server.stop unless @server.stopped?
    sleep(0.01) while GServer.in_service?(@port)
    @server.stop
  end

  it "has :host option" do
    host = "192.168.0.1"
    srv = ModBus::RTUViaTCPServer.new(1010, host: "192.168.0.1")
    expect(srv.host).to eql(host)
  end

  it "has :max_connection option" do
    max_conn = 5
    srv = ModBus::RTUViaTCPServer.new(1010, max_connection: 5)
    expect(srv.maxConnections).to eql(max_conn)
  end

  it "properly ignores responses from other slaves" do
    request = "\x10\x03\x0\x1\x0\x1\xd6\x8b"
    response = "\x10\x83\x1\xd0\xf5"
    expect(@server).to receive(:log).ordered.with("Server RX (8 bytes): [10][03][00][01][00][01][d6][8b]")
    expect(@server).to receive(:log).ordered.with("Server RX function 3 to 16: {:quant=>1, :addr=>1}")
    expect(@server).to receive(:log).ordered.with("Server RX (5 bytes): [10][83][01][d0][f5]")
    expect(@server).to receive(:log).ordered.with("Server RX response 3 from 16: {:err=>1}")
    expect(@server).to receive(:log).ordered.with("Server RX (8 bytes): [01][01][00][00][00][01][fd][ca]")
    expect(@server).to receive(:log).ordered.with("Server RX function 1 to 1: {:quant=>1, :addr=>0}")
    expect(@server).to receive(:log).ordered.with("Server TX (6 bytes): [01][01][01][01][90][48]")
    @io.write(request)
    @io.write(response)
    # just to prove the server can still handle subsequent requests
    expect(@slave.read_coils(0, 1)).to eq([1])
  end

  it "properly ignores functions from other slaves that it doesn't understand" do
    request = "\x10\x41\x0\x1\x0\x1\x0\x5\x0\x1\xb1\x00"
    response = "\x10\xc1\x1\xe0\x55"
    @io.write(request)
    @io.write(response)
    # just to prove the server can still handle subsequent requests
    expect(@slave.read_coils(0, 1)).to eq([1])
  end

  it "properly ignores utter garbage on the line from starting up halfway through a conversation" do
    response = "#{"garbage" * 50}\x01\x55\xe0"
    @io.write(response)
    # just to prove the server can still handle subsequent requests
    expect(@slave.read_coils(0, 1)).to eq([1])
  end

  it "sends exception if request is malformed" do
    expect { @slave.query("\x01\x01") }.to raise_exception(
      ModBus::Errors::ModBusTimeout
    )
  end
end
