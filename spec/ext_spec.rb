# -*- coding: ascii
require 'rmodbus'

describe String do
  before do
    @test = ModBus::Array.new([0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0])
  end

  it "should unpack to @test" do
    "test".unpack_bits == @test
  end
end
