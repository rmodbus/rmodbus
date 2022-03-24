# -*- coding: ascii
require 'rmodbus'

describe ModBus::TCPClient do
  describe "method 'query'" do    
    before(:each) do
      @uid = 1
      @sock = double('Socket')
      @adu = "\000\001\000\000\000\001\001"
  
      expect(Socket).to receive(:tcp).with('127.0.0.1', 1502, nil, nil, hash_including(:connect_timeout)).and_return(@sock)
      allow(@sock).to receive(:read).with(0).and_return('')
      @cl = ModBus::TCPClient.new('127.0.0.1', 1502)
      @slave = @cl.with_slave(@uid)
    end
    
    it 'should send valid MBAP Header' do
      @adu[0,2] = @slave.transaction.next.to_word
      expect(@sock).to receive(:write).with(@adu)
      expect(@sock).to receive(:read).with(7).and_return(@adu)
      expect(@slave.query('')).to eq(nil)
    end
    
    it 'should not throw exception and white next packet if get other transaction' do
      @adu[0,2] = @slave.transaction.next.to_word
      expect(@sock).to receive(:write).with(@adu)
      expect(@sock).to receive(:read).with(7).and_return("\000\002\000\000\000\001" + @uid.chr)
      expect(@sock).to receive(:read).with(7).and_return("\000\001\000\000\000\001" + @uid.chr)

      expect{ @slave.query('') }.to_not raise_error
    end
    
    it 'should throw timeout exception if do not get own transaction' do
      @slave.read_retries = 2
      @adu[0,2] = @slave.transaction.next.to_word
      expect(@sock).to receive(:write).at_least(1).times.with(/\.*/)
      expect(@sock).to receive(:read).at_least(1).times.with(7).and_return("\000\x3\000\000\000\001" + @uid.chr)

      expect{ @slave.query('') }.to raise_error(ModBus::Errors::ModBusTimeout, "Timed out during read attempt")
    end

    
    it 'should return only data from PDU' do
      request = "\x3\x0\x6b\x0\x3"
      response = "\x3\x6\x2\x2b\x0\x0\x0\x64"
      @adu = @slave.transaction.next.to_word + "\x0\x0\x0\x9" + @uid.chr + request
      expect(@sock).to receive(:write).with(@adu[0,4] + "\0\6" + @uid.chr + request)
      expect(@sock).to receive(:read).with(7).and_return(@adu[0,7])
      expect(@sock).to receive(:read).with(8).and_return(response)
  
      expect(@slave.query(request)).to eq(response[2..-1])
    end
    
    it 'should sugar connect method' do
        ipaddr, port = '127.0.0.1', 502
        expect(Socket).to receive(:tcp).with(ipaddr, port, nil, nil, hash_including(:connect_timeout)).and_return(@sock)
        expect(@sock).to receive(:closed?).and_return(false)
        expect(@sock).to receive(:close)
        ModBus::TCPClient.connect(ipaddr, port) do |cl|
          expect(cl.ipaddr).to eq(ipaddr)
          expect(cl.port).to eq(port)
        end
      end
    
    it 'should have closed? method' do
      expect(@sock).to receive(:closed?).and_return(false)
      expect(@cl.closed?).to eq(false)
  
      expect(@sock).to receive(:closed?).and_return(false)
      expect(@sock).to receive(:close)
  
      @cl.close
  
      expect(@sock).to receive(:closed?).and_return(true)
      expect(@cl.closed?).to eq(true)
    end 
    
    it 'should give slave object in block' do
      @cl.with_slave(1) do |slave|
        slave.uid = 1
      end
    end
  end  
  
  it "should tune connection timeout" do
    expect { ModBus::TCPClient.new('81.123.231.11', 1999, :connect_timeout => 0.001) }.to raise_error(ModBus::Errors::ModBusTimeout)
  end
end
