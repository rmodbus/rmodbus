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

  it "should return array of int16" do
    @str = "\x1\x2\x3\x4\x5\x6"
    @str.to_array_int16.should == [0x102, 0x304, 0x506]
  end

end
