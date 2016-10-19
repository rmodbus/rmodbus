module ModBus
  module Options
    attr_accessor :raise_exception_on_mismatch,
                  :read_retries, :read_retry_timeout
  end
end
