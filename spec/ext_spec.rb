require 'rmodbus'

describe Array do

  before do
    @arr = [1,0,1,1, 0,0,1,1, 1,1,0,1, 0,1,1,0,  1,0,1]
  end

  it "should return string reprisent 16bit" do
    @arr.bits_to_bytes.should == "\xcd\x6b\x5" 
  end

  it "should return string reprisent 16ints" do
    @arr = [1,2] 
    @arr.to_ints16 == "\x0\x1\x0\x2"
  end

end

describe String do

  before do
    @str = "\x1\x2\x3\x4\x5\x6"
  end

  it "should return array of int16" do
    @str.to_array_int16.should == [0x102, 0x304, 0x506]
  end

  it "shold return array of bytes" do
    @str.to_array_bytes.should == [1,2,3,4,5,6]
  end

end
