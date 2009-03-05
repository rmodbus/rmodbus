require 'rmodbus'

describe Array do

  before do
    @arr = [1,0,1,1, 0,0,1,1, 1,1,0,1, 0,1,1,0,  1,0,1]
  end

  it "should return string reprisent 16bit" do
    @arr.pack_to_word == "\xcd\x6b\x5" 
  end

end

