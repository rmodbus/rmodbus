# -*- coding: ascii

require "rmodbus"

describe ModBus::TCPServer do
  before :all do
    unit_ids = (1..247).to_a.shuffle
    valid_unit_id = unit_ids.first
    @invalid_unit_id = unit_ids.last
    @port = 8502
    begin
      @server = ModBus::TCPServer.new(@port)
      @server_slave = @server.with_slave(valid_unit_id)
      @server_slave.coils = [1, 0, 1, 1]
      @server_slave.discrete_inputs = [1, 1, 0, 0]
      @server_slave.holding_registers = [1, 2, 3, 4]
      @server_slave.input_registers = [1, 2, 3, 4]
      @server.start
    rescue Errno::EADDRINUSE
      @port += 1
      retry
    end
    @cl = ModBus::TCPClient.new('127.0.0.1', @port)
    @cl.read_retries = 1
    @slave = @cl.with_slave(valid_unit_id)
  end

  it "should succeed if UID is broadcast" do
    @cl.with_slave(0).write_coil(1, 1)
    # have to wait for the server to process it
    sleep 1
    expect(@server_slave.coils[1]).to eq(1)
  end

  it "should fail if UID is mismatched" do
    expect { @cl.with_slave(@invalid_unit_id).read_coils(1, 3) }.to raise_exception(
      ModBus::Errors::ModBusTimeout
    )
  end

  it "should send exception if function not supported" do
    expect { @slave.query('0x43') }.to raise_exception(
      ModBus::Errors::IllegalFunction,
      "The function code received in the query is not an allowable action for the server"
    )
  end

  it "should send exception if quanity of registers are more than 0x7d" do
    expect { @slave.read_holding_registers(0, 0x7e) }.to raise_exception(
      ModBus::Errors::IllegalDataValue,
      "A value contained in the query data field is not an allowable value for server"
    )
  end

  it "shouldn't send exception if quanity of coils are more than 0x7d0" do
    expect { @slave.read_coils(0, 0x7d1) }.to raise_exception(
      ModBus::Errors::IllegalDataValue,
      "A value contained in the query data field is not an allowable value for server"
    )
  end

  it "should send exception if addr not valid" do
    expect { @slave.read_coils(2, 8) }.to raise_exception(
      ModBus::Errors::IllegalDataAddress,
      "The data address received in the query is not an allowable address for the server"
    )
  end

  it "should send exception if function not supported" do
    expect { @slave.query('0x43') }.to raise_exception(
      ModBus::Errors::IllegalFunction,
      "The function code received in the query is not an allowable action for the server"
    )
  end

  it "should calc a many requests" do
    @slave.read_coils(1, 2)
    @slave.write_multiple_registers(0, [9, 9, 9,])
    expect(@slave.read_holding_registers(0, 3)).to eq([9, 9, 9])
  end

  it "should supported function 'read coils'" do
    expect(@slave.read_coils(0, 3)).to eq(@server_slave.coils[0, 3])
  end

  it "should supported function 'read coils' with more than 125 in one request" do
    @server_slave.coils = Array.new(1900, 1)
    expect(@slave.read_coils(0, 1900)).to eq(@server_slave.coils[0, 1900])
  end

  it "should supported function 'read discrete inputs'" do
    expect(@slave.read_discrete_inputs(1, 3)).to eq(@server_slave.discrete_inputs[1, 3])
  end

  it "should supported function 'read holding registers'" do
    expect(@slave.read_holding_registers(0, 3)).to eq(@server_slave.holding_registers[0, 3])
  end

  it "should supported function 'read input registers'" do
    expect(@slave.read_input_registers(2, 2)).to eq(@server_slave.input_registers[2, 2])
  end

  it "should supported function 'write single coil'" do
    @server_slave.coils[3] = 0
    @slave.write_single_coil(3, 1)
    expect(@server_slave.coils[3]).to eq(1)
  end

  it "should supported function 'write single register'" do
    @server_slave.holding_registers[3] = 25
    @slave.write_single_register(3, 35)
    expect(@server_slave.holding_registers[3]).to eq(35)
  end

  it "should supported function 'write multiple coils'" do
    @server_slave.coils = [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1]
    @slave.write_multiple_coils(3, [1, 0, 1, 0, 1, 0, 1, 0, 1])
    expect(@server_slave.coils).to eq([1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1])
  end

  it "should supported function 'write multiple registers'" do
    @server_slave.holding_registers = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    @slave.write_multiple_registers(3, [1, 2, 3, 4, 5])
    expect(@server_slave.holding_registers).to eq([1, 2, 3, 1, 2, 3, 4, 5, 9])
  end

  it "should support function 'mask_write_register'" do
    @server_slave.holding_registers = [0x12]
    @slave.mask_write_register(0, 0xf2, 0x25)
    expect(@server_slave.holding_registers).to eq([0x17])
  end

  it "should support function 'read_write_multiple_registers'" do
    @server_slave.holding_registers = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    expect(@slave.read_write_multiple_registers(0, 5, 4, [3, 2, 1])).to eq([1, 2, 3, 4, 3])
    expect(@server_slave.holding_registers).to eq([1, 2, 3, 4, 3, 2, 1, 8, 9])
  end

  it "should have options :host" do
    host = '192.168.0.1'
    srv = ModBus::TCPServer.new(1010, :host => '192.168.0.1')
    expect(srv.host).to eql(host)
  end

  it "should have options :max_connection" do
    max_conn = 5
    srv = ModBus::TCPServer.new(1010, :max_connection => 5)
    expect(srv.maxConnections).to eql(max_conn)
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
