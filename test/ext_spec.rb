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
