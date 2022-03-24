# -*- coding: ascii
require 'rmodbus'

describe Array do
  before do
    @arr = [1,0,1,1, 0,0,1,1, 1,1,0,1, 0,1,1,0,  1,0,1]
    @test = [0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0]
  end

  it "should return string reprisent 16bit" do
    expect(@arr.pack_to_word).to eq("\xcd\x6b\x5") 
  end

  it "fixed bug for	divisible 8 data " do
    expect(([0] * 8).pack_to_word).to eq("\x00")
  end
  
  it "should unpack to @test" do
    "test".unpack_bits == @test
  end

  it "should turn an array into 32b ints" do
    expect([20342, 17344].to_32i).to eq([1136676726])
    expect([20342, 17344, 20342, 17344].to_32i.size).to eq(2)
  end

  it "should turn an array into 32b floats big endian" do
    expect([20342, 17344].to_32f[0]).to be_within(0.1).of(384.620788574219)
    expect([20342, 17344, 20342, 17344].to_32f.size).to eq(2)
  end
  
  it "should turn a an array into 32b floats (little endian)" do
    expect([17344, 20342].to_32f_le[0]).to be_within(0.1).of(384.620788574219)
    expect([17344, 20342, 17344, 20342].to_32f_le.size).to eq(2)
  end

  it "should turn an array from 32b ints into 16b ints, big endian" do
    expect([1136676726].from_32i).to eq([20342, 17344])
    expect([1136676726, 1136676725].from_32i).to eq([20342, 17344, 20341, 17344])
  end

  it "should turn an array from 32b floats into 16b ints, big endian" do
    expect([384.620788].from_32f).to eq([20342, 17344])
    expect([384.620788, 384.620788].from_32f).to eq([20342, 17344, 20342, 17344])
  end

  it "should raise exception if uneven number of elements" do
   expect { [20342, 17344, 123].to_32f }.to raise_error(StandardError)
   expect { [20342, 17344, 123].to_32i }.to raise_error(StandardError)
  end
end

