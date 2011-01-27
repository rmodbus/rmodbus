require 'rmodbus'

describe Array do

  before do
    @arr = [1,0,1,1, 0,0,1,1, 1,1,0,1, 0,1,1,0,  1,0,1]
    @test = [0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0]
  end

  it "should return string reprisent 16bit" do
    @arr.pack_to_word.should == "\xcd\x6b\x5" 
  end

  it "fixed bug for	divisible 8 data " do
    ([0] * 8).pack_to_word.should == "\x00"
  end
  
  it "should unpack to @test" do
    "test".unpack_bits == @test
  end

end

