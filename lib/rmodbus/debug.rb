module ModBus
  module Debug
    attr_accessor :debug, :raise_exception_on_mismatch,
                  :read_retries, :read_retry_timeout


    private
    # Put log message on standard output
    # @param [String] msg message for log
    def log(msg)
      $stdout.puts msg if @debug
    end

    # Convert string of byte to string for log
    # @example
    #   logging_bytes("\x1\xa\x8") => "[01][0a][08]"
    # @param [String] msg input string
    # @return [String] readable string of bytes
    def logging_bytes(msg)
     result = ""
     msg.each_byte do |c|
       byte = if c < 16
         '0' + c.to_s(16)
       else
          c.to_s(16)
       end
         result << "[#{byte}]"
      end
      result
    end
  end
end
