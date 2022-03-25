# -*- coding: ascii
# frozen_string_literal: true

describe ModBus::Errors do
  before(:all) do
    @srv = ModBus::TCPServer.new(1502)
    srv_slave = @srv.with_slave(1)
    srv_slave.coils = [0] * 8
    srv_slave.discrete_inputs = [0] * 8
    srv_slave.holding_registers = [0] * 8
    srv_slave.input_registers = [0] * 8
    @srv.start

    @cl = ModBus::TCPClient.new("127.0.0.1", 1502)
    @slave = @cl.with_slave(1)
  end

  after(:all) do
    @cl.close unless @cl.closed?
    @srv.stop
  end

  it "raises ProxException" do
    expect { @slave.holding_registers[0..2] = [0, 0] }.to raise_error(ModBus::Errors::ProxyException)
  end

  context "when reading coil status" do
    it "doesn't raise exception when valid" do
      expect(@slave.read_coils(0, 4)).to eq([0] * 4)
    end

    it "raises exception if illegal data address" do
      expect { @slave.read_coils(501, 34) }.to raise_error(ModBus::Errors::IllegalDataAddress)
    end

    it "raises exception if too many data" do
      expect { @slave.read_coils(0, 0x07D1) }.to raise_error(ModBus::Errors::IllegalDataValue)
    end
  end

  context "when reading discrete inputs" do
    it "doesn't raise exception when valid" do
      expect(@slave.read_discrete_inputs(0, 4)).to eq([0] * 4)
    end

    it "raises exception if illegal data address" do
      expect { @slave.read_discrete_inputs(50, 23) }.to raise_error(ModBus::Errors::IllegalDataAddress)
    end

    it "raises exception if too many data" do
      expect { @slave.read_discrete_inputs(0, 0x07D1) }.to raise_error(ModBus::Errors::IllegalDataValue)
    end
  end

  context "when reading holding registers" do
    it "doesn't raise exception when valid" do
      expect(@slave.read_holding_registers(0, 4)).to eq([0, 0, 0, 0])
    end

    it "raises exception if illegal data address" do
      expect { @slave.read_holding_registers(402, 99) }.to raise_error(ModBus::Errors::IllegalDataAddress)
    end

    it "raises exception if too many data" do
      expect { @slave.read_holding_registers(0, 0x007E) }.to raise_error(ModBus::Errors::IllegalDataValue)
    end
  end

  context "when reading input registers" do
    it "doesn't raise exception when valid" do
      expect(@slave.read_input_registers(0, 4)).to eq([0, 0, 0, 0])
    end

    it "raises exception if illegal data address" do
      expect { @slave.read_input_registers(402, 9) }.to raise_error(ModBus::Errors::IllegalDataAddress)
    end

    it "raises exception if too many data" do
      expect { @slave.read_input_registers(0, 0x007E) }.to raise_error(ModBus::Errors::IllegalDataValue)
    end
  end

  context "when writing a single coil" do
    it "doesn't raise exception when valid" do
      expect(@slave.write_single_coil(4, 1)).to eq(@slave)
      expect(@slave.read_coils(4, 4)).to eq([1, 0, 0, 0])
    end

    it "raises exception if illegal data address" do
      expect { @slave.write_single_coil(501, true) }.to raise_error(ModBus::Errors::IllegalDataAddress)
    end
  end

  context "when writing a single register" do
    it "doesn't raise exception when valid" do
      expect(@slave.write_single_register(4, 0x0AA0)).to eq(@slave)
      expect(@slave.read_holding_registers(4, 1)).to eq([0x0AA0])
    end

    it "raises exception if illegal data address" do
      expect { @slave.write_single_register(501, 0x0AA0) }.to raise_error(ModBus::Errors::IllegalDataAddress)
    end
  end

  context "when writing multiple coils" do
    it "doesn't raise exception when valid" do
      expect(@slave.write_multiple_coils(4, [0, 1, 0, 1])).to eq(@slave)
      expect(@slave.read_coils(3, 5)).to eq([0, 0, 1, 0, 1])
    end

    it "raises exception if illegal data address" do
      expect { @slave.write_multiple_coils(501, [1, 0]) }.to raise_error(ModBus::Errors::IllegalDataAddress)
    end
  end

  context "when writing multiple registers" do
    it "doesn't raise exception when valid" do
      expect(@slave.write_multiple_registers(4, [1, 2, 3, 0xAACC])).to eq(@slave)
      expect(@slave.read_holding_registers(3, 5)).to eq([0, 1, 2, 3, 0xAACC])
    end

    it "raises exception if illegal data address" do
      expect { @slave.write_multiple_registers(501, [1, 2]) }.to raise_error(ModBus::Errors::IllegalDataAddress)
    end
  end
end
