# -*- coding: ascii
# frozen_string_literal: true

describe ModBus::Client::Slave do
  before do
    @slave = ModBus::Client.new.with_slave(1)

    allow(@slave).to receive(:query).and_return("")
  end

  it "supports function 'read coils'" do
    expect(@slave).to receive(:query).with("\x1\x0\x13\x0\x13").and_return("\xcd\x6b\x5")
    expect(@slave.read_coils(0x13, 0x13)).to eq([1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1])
  end

  it "supports function 'read discrete inputs'" do
    expect(@slave).to receive(:query).with("\x2\x0\xc4\x0\x16").and_return("\xac\xdb\x35")
    expect(@slave.read_discrete_inputs(0xc4,
                                       0x16)).to eq([0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1])
  end

  it "supports function 'read holding registers'" do
    expect(@slave).to receive(:query).with("\x3\x0\x6b\x0\x3").and_return("\x2\x2b\x0\x0\x0\x64")
    expect(@slave.read_holding_registers(0x6b, 0x3)).to eq([0x022b, 0x0000, 0x0064])
  end

  it "supports function 'read input registers'" do
    expect(@slave).to receive(:query).with("\x4\x0\x8\x0\x1").and_return("\x0\xa")
    expect(@slave.read_input_registers(0x8, 0x1)).to eq([0x000a])
  end

  it "supports function 'write single coil'" do
    expect(@slave).to receive(:query).with("\x5\x0\xac\xff\x0").and_return("\xac\xff\x00")
    expect(@slave.write_single_coil(0xac, 0x1)).to eq(@slave)
  end

  it "supports function 'write single register'" do
    expect(@slave).to receive(:query).with("\x6\x0\x1\x0\x3").and_return("\x1\x0\x3")
    expect(@slave.write_single_register(0x1, 0x3)).to eq(@slave)
  end

  it "supports function 'write multiple coils'" do
    expect(@slave).to receive(:query).with("\xf\x0\x13\x0\xa\x2\xcd\x1").and_return("\x13\x0\xa")
    expect(@slave.write_multiple_coils(0x13, [1, 0, 1, 1, 0, 0, 1, 1, 1, 0])).to eq(@slave)
  end

  it "supports function 'write multiple registers'" do
    expect(@slave).to receive(:query).with("\x10\x0\x1\x0\x3\x6\x0\xa\x1\x2\xf\xf").and_return("\x1\x0\x3")
    expect(@slave.write_multiple_registers(0x1, [0x000a, 0x0102, 0xf0f])).to eq(@slave)
  end

  it "supports function 'mask write register'" do
    expect(@slave).to receive(:query).with("\x16\x0\x4\x0\xf2\x0\2").and_return("\x4\x0\xf2\x0\x2")
    expect(@slave.mask_write_register(0x4, 0xf2, 0x2)).to eq(@slave)
  end
end
