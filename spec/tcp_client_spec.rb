# -*- coding: ascii
require 'rmodbus'

describe ModBus::TCPClient do
  describe "method 'query'" do    
    before(:each) do
      @uid = 1
      @sock = mock("Socket")
      @adu = "\000\001\000\000\000\001\001"
  
      TCPSocket.should_receive(:new).with('127.0.0.1', 1502).and_return(@sock)
      @sock.stub!(:sysread).with(0).and_return('')
      @sock.stub!(:syswrite){|msg| msg.size}
      @sock.should_receive(:flush).any_number_of_times
      @sock.should_receive(:fcntl).any_number_of_times
          
      @cl = ModBus::TCPClient.new('127.0.0.1', 1502)
      @slave = @cl.with_slave(@uid)
      @slave.stub!(:read_ready?){|array| array }
      @slave.stub!(:write_ready?){|array| array }
    end
    
    it 'should send a valid MBAP Header' do
      @adu[0,2] = @slave.transaction.next.to_word
      @sock.should_receive(:syswrite).with(@adu)
      @sock.should_receive(:sysread).any_number_of_times.with(7).and_return(@adu)
      
      #empty query causes an empty reply in the mock object
      #Slave#query catches it and throws a timeout, because we have
      #timed out after the header and before the data
      expect{ @slave.query('') }.to raise_error(ModBus::Errors::ModBusTimeout, "Response Failure")
    end
    
# this test removed because we now throw an exception if we have a mismatch
# because we have a query lock to stop two queries trying to happen simultaneously 
#    it 'should not throw exception and write next packet if get other transaction' do
#      @adu[0,2] = @slave.transaction.next.to_word
#      @sock.should_receive(:write).with(@adu)
#      @sock.should_receive(:read).with(7).and_return("\000\002\000\000\000\001" + @uid.chr)
#      @sock.should_receive(:read).with(7).and_return("\000\001\000\000\000\001" + @uid.chr)
#
#      expect{ @slave.query('') }.to_not raise_error
#    end
    
    
    #we now have Thread-safe transactional processing, so a wrong transaction number is pretty serious!
    #it is not just a case of ignoring it and moving on.
    it 'should throw ModBusTimeout exception if it does not get own transaction' do
      @slave.read_retries = 2
      @adu[0,2] = @slave.transaction.next.to_word
      @sock.should_receive(:write).any_number_of_times.with(/\.*/)
      @sock.should_receive(:read).any_number_of_times.with(7).and_return("\000\x3\000\000\000\001" + @uid.chr)
      @sock.should_receive(:flush).any_number_of_times
      
      expect{ @slave.query('') }.to raise_error(ModBus::Errors::ModBusTimeout, "Response Failure")
    end

    
    it 'should return only data from PDU' do
      request = "\x3\x0\x6b\x0\x3"
      response = "\x3\x6\x2\x2b\x0\x0\x0\x64"
      @adu = @slave.transaction.next.to_word + "\x0\x0\x0\x9" + @uid.chr + request
      @sock.should_receive(:syswrite).with(@adu[0,4] + "\0\6" + @uid.chr + request)
      @sock.should_receive(:sysread).with(7).and_return(@adu[0,7])
      @sock.should_receive(:sysread).with(8).and_return(response)
      @sock.should_receive(:flush).any_number_of_times
      
  
      @slave.query(request).should == response[2..-1]
    end
    
    it 'should sugar connect method' do
        ipaddr, port = '127.0.0.1', 502
        TCPSocket.should_receive(:new).with(ipaddr, port).and_return(@sock)
        @sock.should_receive(:closed?).and_return(false)
        @sock.should_receive(:close)
        ModBus::TCPClient.connect(ipaddr, port) do |cl|
          cl.ipaddr.should == ipaddr
          cl.port.should == port
        end
      end
    
    it 'should have closed? method' do
      @sock.should_receive(:closed?).and_return(false)
      @cl.closed?.should == false
  
      @sock.should_receive(:closed?).and_return(false)
      @sock.should_receive(:close)
  
      @cl.close
  
      @sock.should_receive(:closed?).and_return(true)
      @cl.closed?.should == true
    end 
    
    it 'should give slave object in block' do
      @cl.with_slave(1) do |slave|
        slave.uid = 1
      end
    end
  end  
  
  it "should tune connection timeout" do
    lambda { ModBus::TCPClient.new('81.123.231.11', 1999, :connect_timeout => 0.001) }.should raise_error(ModBus::Errors::ModBusTimeout)
  end
end
