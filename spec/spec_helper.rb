# -*- coding: ascii
# frozen_string_literal: true

require "rmodbus"

RSpec::Matchers.define :raise_response_mismatch do |expected_message, expected_request, expected_response|
  supports_block_expectations

  match do |given_block|
    begin
      given_block.call
    rescue ModBus::Errors::ResponseMismatch => e
      @actual_message = e.message
      @actual_request = e.request
      @actual_response = e.response

      @with_expected_message = case expected_message
                               when nil
                                 true
                               when Regexp
                                 expected_message =~ @actual_message
                               else
                                 expected_message == @actual_message
                               end
      @with_expected_request = expected_request == @actual_request
      @with_expected_response = expected_response == @actual_response
    end
    @with_expected_message & @with_expected_request & @with_expected_response
  end

  failure_message do
    return "Expected message '#{expected_message}', got '#{@actual_message}'" unless @with_expected_message

    unless @with_expected_request
      return "Expected request #{logging_bytes expected_request}, got #{logging_bytes @actual_request}"
    end

    unless @with_expected_response
      return "Expected response #{logging_bytes expected_response}, got #{logging_bytes @actual_response}"
    end
  end
end
