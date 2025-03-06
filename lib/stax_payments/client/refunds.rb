# frozen_string_literal: true

module StaxPayments
  class Client
    module Refunds
      # List all refunds
      # @param args [Hash] Optional parameters
      # @return [Array<StaxPayments::Refund>] Array of refund objects
      def refunds(args = {})
        results = process_request(:get, '/refunds', params: args)
        return results if results.is_a?(StaxError)

        results[:refunds]&.map { |result| StaxPayments::Refund.new(result) } || []
      end
      alias list_refunds refunds

      # Get a specific refund
      # @param refund_id [String] The ID of the refund to retrieve
      # @return [StaxPayments::Refund] The refund object
      def refund(refund_id)
        result = process_request(:get, "/refunds/#{refund_id}")
        return result if result.is_a?(StaxError)

        StaxPayments::Refund.new(result[:refund])
      end
      alias get_refund refund

      # Create a new refund
      # @param payment_id [String] The ID of the payment to refund
      # @param args [Hash] Refund details (e.g., amount)
      # @return [StaxPayments::Refund] The created refund object
      def create_refund(payment_id, args = {})
        args[:payment_id] = payment_id
        result = process_request(:post, '/refunds', body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Refund.new(result[:refund])
      end
    end
  end
end
