describe "response mismach" do
  before(:each) do
    @slave = Slave.new(1, nil)
    @slave.raise_exception_on_mismatch = true
  end

  it "should raise error if function code is mismatch" do
    request = "\x1\x0\x13\x0\x12"
    response = "\x2\x2\xcd\xb6\x5"
    @slave.should_receive(:send_pdu).with(request)
    @slave.should_receive(:read_pdu).and_return(response)
    lambda{ @slave.read_coils(0x13,0x12) }.should raise_error(
      ModBus::Errors::ResponseMismatch,
      "Function code is mismatch: expected 1, got 2"
    )
  end
end