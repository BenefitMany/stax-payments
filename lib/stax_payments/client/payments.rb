# frozen_string_literal: true

module StaxPayments
  class Client
    module Payments
      # List all payments
      # @param args [Hash] Optional parameters
      # @return [Array<StaxPayments::Payment>] Array of payment objects
      def payments(args = {})
        results = process_request(:get, 'payments', params: args)
        return results if results.is_a?(StaxError)

        results[:payments]&.map { |result| StaxPayments::Payment.new(result) } || []
      end
      alias list_payments payments

      # Get a specific payment
      # @param payment_id [String] The ID of the payment to retrieve
      # @return [StaxPayments::Payment] The payment object
      def payment(payment_id)
        result = process_request(:get, "payments/#{payment_id}")
        return result if result.is_a?(StaxError)

        StaxPayments::Payment.new(result[:payment])
      end
      alias get_payment payment

      # Create a new payment
      # @param args [Hash] Payment details
      # @return [StaxPayments::Payment] The created payment object
      def create_payment(args = {})
        result = process_request(:post, 'payments', body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Payment.new(result[:payment])
      end

      # Capture an authorized payment
      # @param payment_id [String] The ID of the payment to capture
      # @param args [Hash] Optional parameters (amount, etc.)
      # @return [StaxPayments::Payment] The captured payment object
      def capture_payment(payment_id, args = {})
        result = process_request(:post, "payments/#{payment_id}/capture", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Payment.new(result[:payment])
      end

      # Void a payment
      # @param payment_id [String] The ID of the payment to void
      # @return [StaxPayments::Payment] The voided payment object
      def void_payment(payment_id)
        result = process_request(:post, "payments/#{payment_id}/void")
        return result if result.is_a?(StaxError)

        StaxPayments::Payment.new(result[:payment])
      end
    end
  end
end
