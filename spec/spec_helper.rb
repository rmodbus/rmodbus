# -*- coding: ascii
require "rmodbus"

class RaiseResponseMismatch
  def initialize(message, request, response)
    @expected_message, @expected_request, @expected_response = message, request, response
  end

  def matches?(given_block)
    begin
      given_block.call
    rescue ModBus::Errors::ResponseMismatch => e
      @actual_message = e.message
      @actual_request = e.request
      @actual_response = e.response

      @with_expected_message = verify_message
      @with_expected_request = @expected_request == @actual_request
      @with_expected_response = @expected_response == @actual_response
    end
    @with_expected_message & @with_expected_request & @with_expected_response
  end

  def failure_message
    unless @with_expected_message
      return "Expected message '#{@expected_message}', got '#{@actual_message}'"
    end

    unless @with_expected_request
      return "Expected request #{logging_bytes @expected_request}, got #{logging_bytes @actual_request}"
    end

    unless @with_expected_response
      return "Expected response #{logging_bytes @expected_response}, got #{logging_bytes @actual_response}"
    end
  end

  def verify_message
    case  @expected_message
      when nil
        true
      when Regexp
         @expected_message =~ @actual_message
      else
         @expected_message == @actual_message
    end
  end
end

module RaiseResponseMatcher
  def raise_response_mismatch(message, request, response)
    RaiseResponseMismatch.new(message, request, response)
  end
end
