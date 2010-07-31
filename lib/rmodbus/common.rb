module ModBus
	module Common

		private
		def log(msg)
			$stdout.puts msg if @debug
		end

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

