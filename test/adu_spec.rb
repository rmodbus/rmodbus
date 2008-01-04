require 'lib/rmodbus/adu'

include ModBus

describe ADU do

  def valid_pdu 
    "\x03\x00\x00\x01"
  end

  before do
    @adu = ADU.new(valid_pdu, 1)  
  end

  it 'should have unit id' do 
    @adu.unit_id.should == 1
  end

  it 'should have unique transaction id' do
    @adu.transaction_id.should_not == ADU.new(valid_pdu, 1).transaction_id
  end


  it 'should have fild of size = pdu size + 1' do
    @adu.size.should == valid_pdu.size + 1
  end

  it 'should have fild of pdu' do
    @adu.pdu.should == valid_pdu
  end

  it 'should have serialize in string' do
    @adu.serialize.should == @adu.transaction_id.to_bytes + "\x00\x00" + @adu.size.to_bytes + @adu.unit_id.chr + valid_pdu
  end

end
