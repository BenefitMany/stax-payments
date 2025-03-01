# frozen_string_literal: true

module StaxPayments
  class StaxError < StandardError
    attr_reader :code, :message, :response

    def initialize(response = nil)
      @response = response
      @message = parse_error_message
      @code = response&.code
      super(@message)
    end

    private

    def parse_error_message
      return 'Unknown error' if @response.nil?

      if @response.body && !@response.body.empty?
        begin
          error_data = JSON.parse(@response.body, symbolize_names: true)
          return error_data[:error][:message] if error_data[:error] && error_data[:error][:message]
          return error_data[:message] if error_data[:message]
          return error_data.to_s
        rescue JSON::ParserError
          # If we can't parse the JSON, just return the body
          return @response.body
        end
      end

      "HTTP Status: #{@response.code}"
    end
  end
end
