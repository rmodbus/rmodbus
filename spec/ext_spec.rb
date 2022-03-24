# -*- coding: ascii
# frozen_string_literal: true

require "rmodbus"

describe Array do
  before do
    @arr = [1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0,  1, 0, 1]
    @test = [0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0]
  end

  it "returns string reprisent 16bit" do
    expect(@arr.pack_to_word).to eq("\xcd\x6b\x5")
  end

  it "fixed bug for	divisible 8 data" do
    expect(([0] * 8).pack_to_word).to eq("\x00")
  end

  it "unpacks to @test" do
    "test".unpack_bits == @test
  end

  it "turns an array into 32b ints" do
    expect([20_342, 17_344].to_32i).to eq([1_136_676_726])
    expect([20_342, 17_344, 20_342, 17_344].to_32i.size).to eq(2)
  end

  it "turns an array into 32b floats big endian" do
    expect([20_342, 17_344].to_32f[0]).to be_within(0.1).of(384.620788574219)
    expect([20_342, 17_344, 20_342, 17_344].to_32f.size).to eq(2)
  end

  it "turns an array into 32b floats (little endian)" do
    expect([17_344, 20_342].to_32f_le[0]).to be_within(0.1).of(384.620788574219)
    expect([17_344, 20_342, 17_344, 20_342].to_32f_le.size).to eq(2)
  end

  it "turns an array from 32b ints into 16b ints, big endian" do
    expect([1_136_676_726].from_32i).to eq([20_342, 17_344])
    expect([1_136_676_726, 1_136_676_725].from_32i).to eq([20_342, 17_344, 20_341, 17_344])
  end

  it "turns an array from 32b floats into 16b ints, big endian" do
    expect([384.620788].from_32f).to eq([20_342, 17_344])
    expect([384.620788, 384.620788].from_32f).to eq([20_342, 17_344, 20_342, 17_344])
  end

  it "raises exception if uneven number of elements" do
    expect { [20_342, 17_344, 123].to_32f }.to raise_error(StandardError)
    expect { [20_342, 17_344, 123].to_32i }.to raise_error(StandardError)
  end
end
