# -*- coding: ascii
require 'rmodbus'

#Use public wrap method
class ModBus::Slave
  include ModBus::RTU
  def test_read_method(msg)
    io = TestIO.new(msg)
    read_rtu_response(io)
  end
  
  def read_ready?(timeout)
    true
  end
  alias :write_ready? :read_ready?


end

class TestIO
  attr_accessor :read_timeout
  
  def initialize(msg)
    @msg = msg
    @read_timeout=100
  end

  def sysread(num)
    result = @msg[0,num]
    @msg = @msg[num..-1]
    result
  end
  
  def t_3_5
    0.01
  end
    
end

describe "#read_rtu_response" do
  before do
    @cl_mb = ModBus::Slave.new(1,nil)  
  end

  it "should read response for 'read coils'" do
    resp = make_resp("\x1\x3\xcd\x6b\x05")
    @cl_mb.test_read_method(resp).should == resp 
  end

  it "should read response for 'read discrete inputs'" do
    resp = make_resp("\x2\x3\xac\xdb\x35")
    @cl_mb.test_read_method(resp).should == resp 
  end

  it "should read response for 'read holding registers'" do
    resp = make_resp("\x3\x6\x2\x2b\x0\x0\x0\x64")
    @cl_mb.test_read_method(resp).should == resp 
  end

  it "should read response for 'read input registers'" do
    resp = make_resp("\x4\x2\x0\xa")
    @cl_mb.test_read_method(resp).should == resp 
  end

  it "should read response for 'write single coil'" do
    resp = make_resp("\x5\x0\xac\xff\x0")
    @cl_mb.test_read_method(resp).should == resp 
  end

  it "should read response for 'write single register'" do
    resp = make_resp("\x6\x0\x1\x0\x3")
    @cl_mb.test_read_method(resp).should == resp 
  end

  it "should read response for 'write multiple coils'" do
    resp = make_resp("\xf\x0\x13\x0\xa")
    @cl_mb.test_read_method(resp).should == resp 
  end

  it "should read response for 'write multiple registers'" do
    resp = make_resp("\x10\x0\x1\x0\x2")
    @cl_mb.test_read_method(resp).should == resp 
  end

  it "should read response 'mask write register'" do
    resp = make_resp("\x16\x0\x4\x0\xf2\x0\x25")
    @cl_mb.test_read_method(resp).should == resp 
  end

  it "should read exception codes" do
    resp = make_resp("\x84\x3")
    @cl_mb.test_read_method(resp).should == resp 
  end

  it "should raise exception if function is illegal" do
    resp = make_resp("\xff\x0\x1\x0\x2").should raise_error {
      ModBus::Errors::IllegalFunction
    }
  end

  def make_resp(msg)
    "\x1" + msg + "\x2\x2" # slave + msg + mock_crc
  end
end

