require 'time'

module ModBus
  module Debug
    attr_accessor :debug, :raise_exception_on_mismatch,
                  :read_retries, :read_retry_timeout


    private
    # Put log message on standard output
    # @param [String] msg message for log
    def log(msg)
      $stdout.puts "#{Time.now.utc.iso8601(2)} #{msg}" if @debug
    end

    # Convert string of byte to string for log
    # @example
    #   logging_bytes("\x1\xa\x8") => "[01][0a][08]"
    # @param [String] msg input string
    # @return [String] readable string of bytes
    def logging_bytes(msg)
      msg.unpack("H*").first.gsub(/\X{2}/, "[\\0]")
    end
  end
end
