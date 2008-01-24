require 'rmodbus/rtu_client'

include ModBus

describe RTUClient do

  before do
    @mb_cl = RTUClient.new(1, 9600, UID)
  end

 # it "should 

end
