# frozen_string_literal: true

module StaxPayments
  class Client
    module Payments
      # List all payments
      # @param args [Hash] Optional parameters
      # @return [Array<StaxPayments::Payment>] Array of payment objects
      def payments(args = {})
        results = process_request(:get, '/payments', params: args)
        return results if results.is_a?(StaxError)

        results[:payments]&.map { |result| StaxPayments::Payment.new(result) } || []
      end
      alias list_payments payments

      # Get a specific payment
      # @param payment_id [String] The ID of the payment to retrieve
      # @return [StaxPayments::Payment] The payment object
      def payment(payment_id)
        result = process_request(:get, "/payments/#{payment_id}")
        return result if result.is_a?(StaxError)

        StaxPayments::Payment.new(result[:payment])
      end
      alias get_payment payment

      # Create a new payment
      # @param args [Hash] Payment details
      # @return [StaxPayments::Payment] The created payment object
      def create_payment(args = {})
        result = process_request(:post, '/payments', body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Payment.new(result[:payment])
      end

      # Capture an authorized payment
      # @param payment_id [String] The ID of the payment to capture
      # @param args [Hash] Optional parameters (amount, etc.)
      # @return [StaxPayments::Payment] The captured payment object
      def capture_payment(payment_id, args = {})
        result = process_request(:post, "/payments/#{payment_id}/capture", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Payment.new(result[:payment])
      end

      # Void a payment
      # @param payment_id [String] The ID of the payment to void
      # @return [StaxPayments::Payment] The voided payment object
      def void_payment(payment_id)
        result = process_request(:post, "/payments/#{payment_id}/void")
        return result if result.is_a?(StaxError)

        StaxPayments::Payment.new(result[:payment])
      end

      # Charge a payment method
      # @param args [Hash] Charge details
      # @option args [String] :payment_method_id (required) The ID of the payment method to charge
      # @option args [Float, String] :total (required) The amount to charge in dollars and cents (min: 0.01)
      # @option args [Hash] :meta (required) Metadata about the charge
      # @option args [Boolean] :pre_auth Whether to create a pre-authorization (default: false)
      # @option args [String] :invoice_id Optional. The ID of an invoice to associate with this charge
      # @option args [String] :currency Optional. The currency to use (default: "USD")
      # @option args [String] :idempotency_id Optional. A unique string identifier to prevent duplicate charges (max 255 characters)
      # @option args [String] :channel Optional. A way to identify where the transaction originated
      # @option args [Array] :funding Optional. Defines how funds should be paid out (requires Split Funding feature)
      # @return [StaxPayments::Transaction] The transaction object
      # @example
      #   # Basic charge
      #   transaction = client.charge_payment_method({
      #     payment_method_id: 'b5f8729c-93ee-4bbb-9bfe-4a71f7b0e126',
      #     total: 26.00,
      #     meta: {
      #       tax: 4,
      #       subtotal: 20,
      #       lineItems: [
      #         {
      #           item: 'Demo Item',
      #           details: 'this is a regular demo item',
      #           quantity: 20,
      #           price: 1
      #         }
      #       ]
      #     },
      #     pre_auth: false
      #   })
      #
      #   # Charge with additional options
      #   transaction = client.charge_payment_method({
      #     payment_method_id: 'b5f8729c-93ee-4bbb-9bfe-4a71f7b0e126',
      #     total: 26.00,
      #     meta: {
      #       tax: 4,
      #       poNumber: '1234',
      #       shippingAmount: 2,
      #       payment_note: 'This note displays in Stax Pay',
      #       subtotal: 20,
      #       lineItems: [
      #         {
      #           id: 'optional-fm-catalog-item-id',
      #           item: 'Demo Item',
      #           details: 'this is a regular demo item',
      #           quantity: 20,
      #           price: 1
      #         }
      #       ]
      #     },
      #     pre_auth: false,
      #     currency: 'USD',
      #     idempotency_id: 'unique-transaction-id-123',
      #     channel: 'web-application'
      #   })
      def charge_payment_method(args = {})
        # Validate required parameters
        validate_charge_params(args)

        result = process_request(:post, '/charge', body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Transaction.new(result)
      end

      # Verify a payment method
      # @param args [Hash] Verification details
      # @option args [String] :payment_method_id (required) The ID of the payment method to verify
      # @option args [Float, String] :total (required) The amount to charge for verification (min: 0.01)
      # @option args [Hash] :meta (required) Metadata about the verification
      # @option args [Boolean] :pre_auth Whether to create a pre-authorization (default: true)
      # @return [StaxPayments::Transaction] The transaction object
      # @example
      #   # Verify a payment method
      #   transaction = client.verify_payment_method({
      #     payment_method_id: 'b5f8729c-93ee-4bbb-9bfe-4a71f7b0e126',
      #     total: 1.00,
      #     meta: {
      #       tax: 0,
      #       subtotal: 1.00
      #     },
      #     pre_auth: true
      #   })
      def verify_payment_method(args = {})
        # Validate required parameters
        validate_verify_params(args)

        # Set pre_auth to true by default if not specified
        args[:pre_auth] = true unless args.key?(:pre_auth)

        result = process_request(:post, '/verify', body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Transaction.new(result)
      end

      # Credit a payment method (refund money to the customer)
      # @param args [Hash] Credit details
      # @option args [String] :payment_method_id (required) The ID of the payment method to credit
      # @option args [Float, String] :total (required) The amount to credit in dollars and cents (min: 0.01)
      # @option args [Hash] :meta (required) Metadata about the credit
      # @return [StaxPayments::Transaction] The transaction object
      # @example
      #   # Credit a payment method
      #   transaction = client.credit_payment_method({
      #     payment_method_id: 'b5f8729c-93ee-4bbb-9bfe-4a71f7b0e126',
      #     total: 1.00,
      #     meta: {
      #       memo: 'Refund for Subscription',
      #       subtotal: '1.00',
      #       tax: '0'
      #     }
      #   })
      def credit_payment_method(args = {})
        # Validate required parameters
        validate_credit_params(args)

        result = process_request(:post, '/creditRequest', body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Transaction.new(result)
      end

      private

      # Validate charge parameters
      # @param args [Hash] Charge parameters to validate
      # @raise [StaxError] If any required parameters are missing or invalid
      def validate_charge_params(args)
        # Check required fields
        unless args[:payment_method_id]
          raise StaxError, 'The payment_method_id field is required'
        end

        unless args[:total]
          raise StaxError, 'The total field is required'
        end

        # Validate total is a positive number
        if args[:total].to_f <= 0
          raise StaxError, 'The total must be greater than 0'
        end

        unless args[:meta]
          raise StaxError, 'The meta field is required'
        end

        # Validate pre_auth is a boolean if provided
        if args.key?(:pre_auth) && ![true, false, 0, 1].include?(args[:pre_auth])
          raise StaxError, 'The pre_auth field must be a boolean value'
        end

        # Validate idempotency_id length if provided
        if args[:idempotency_id] && args[:idempotency_id].to_s.length > 255
          raise StaxError, 'The idempotency_id must not exceed 255 characters'
        end

        # Validate currency if provided
        if args[:currency] && args[:currency] != 'USD'
          raise StaxError, 'Currently, only USD is supported as a currency'
        end

        # Validate funding array if provided
        if args[:funding]
          unless args[:funding].is_a?(Array)
            raise StaxError, 'The funding field must be an array'
          end

          args[:funding].each_with_index do |fund, index|
            unless fund[:account_id]
              raise StaxError, "The funding.#{index}.account_id field is required"
            end

            unless fund[:amount].is_a?(Numeric) || fund[:amount].to_s =~ /\A\d+(\.\d+)?\z/
              raise StaxError, "The funding.#{index}.amount must be a number"
            end
          end
        end

        # Validate transaction meta types if provided
        if args[:meta]
          if args[:meta][:transaction_initiation_type] && !%w[MIT CIT].include?(args[:meta][:transaction_initiation_type])
            raise StaxError, 'The transaction_initiation_type must be either MIT or CIT'
          end

          if args[:meta][:transaction_schedule_type] && !%w[scheduled unscheduled].include?(args[:meta][:transaction_schedule_type])
            raise StaxError, 'The transaction_schedule_type must be either scheduled or unscheduled'
          end
        end
      end

      # Validate verify parameters
      # @param args [Hash] Verify parameters to validate
      # @raise [StaxError] If any required parameters are missing or invalid
      def validate_verify_params(args)
        # Check required fields
        unless args[:payment_method_id]
          raise StaxError, 'The payment_method_id field is required'
        end

        unless args[:total]
          raise StaxError, 'The total field is required'
        end

        # Validate total is a positive number
        if args[:total].to_f <= 0
          raise StaxError, 'The total must be greater than 0'
        end

        unless args[:meta]
          raise StaxError, 'The meta field is required'
        end

        # Validate pre_auth is a boolean if provided
        if args.key?(:pre_auth) && ![true, false, 0, 1].include?(args[:pre_auth])
          raise StaxError, 'The pre_auth field must be a boolean value'
        end
      end

      # Validate credit parameters
      # @param args [Hash] Credit parameters to validate
      # @raise [StaxError] If any required parameters are missing or invalid
      def validate_credit_params(args)
        # Check required fields
        unless args[:payment_method_id]
          raise StaxError, 'The payment_method_id field is required'
        end

        unless args[:total]
          raise StaxError, 'The total field is required'
        end

        # Validate total is a positive number
        if args[:total].to_f <= 0
          raise StaxError, 'The total must be greater than 0'
        end

        unless args[:meta]
          raise StaxError, 'The meta field is required'
        end
      end
    end
  end
end
