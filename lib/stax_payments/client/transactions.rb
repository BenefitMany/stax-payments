# frozen_string_literal: true

module StaxPayments
  class Client
    module Transactions
      # List all transactions
      # @param args [Hash] Optional parameters for filtering, pagination, etc.
      # @option args [String] :customer_id Filter by customer ID
      # @option args [String] :payment_method_id Filter by payment method ID
      # @option args [String] :status Filter by status
      # @option args [String] :type Filter by type
      # @option args [String] :start_date Filter by start date (ISO 8601 format)
      # @option args [String] :end_date Filter by end date (ISO 8601 format)
      # @option args [Integer] :page Page number for pagination
      # @option args [Integer] :per_page Number of results per page
      # @return [Array<StaxPayments::Transaction>] Array of transaction objects
      def transactions(args = {})
        results = process_request(:get, '/transactions', params: args)
        return results if results.is_a?(StaxError)

        results[:transactions]&.map { |result| StaxPayments::Transaction.new(result) } || []
      end
      alias list_transactions transactions

      # Get a specific transaction
      # @param transaction_id [String] The ID of the transaction to retrieve
      # @return [StaxPayments::Transaction] The transaction object
      def transaction(transaction_id)
        result = process_request(:get, "/transactions/#{transaction_id}")
        return result if result.is_a?(StaxError)

        StaxPayments::Transaction.new(result[:transaction])
      end
      alias get_transaction transaction

      # Update a transaction
      # @param transaction_id [String] The ID of the transaction to update
      # @param args [Hash] Update parameters
      # @return [StaxPayments::Transaction] The updated transaction object
      def update_transaction(transaction_id, args = {})
        result = process_request(:put, "/transactions/#{transaction_id}", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Transaction.new(result[:transaction])
      end

      # Void or refund a transaction
      # @param transaction_id [String] The ID of the transaction to void or refund
      # @param args [Hash] Optional parameters
      # @option args [Float] :total Amount to refund (for partial refunds)
      # @return [StaxPayments::Transaction] The transaction object
      def void_or_refund_transaction(transaction_id, args = {})
        result = process_request(:post, "/transactions/#{transaction_id}/void-or-refund", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Transaction.new(result[:transaction])
      end

      # Search transactions with advanced filtering
      # @param args [Hash] Search parameters
      # @option args [String] :customer_id Filter by customer ID
      # @option args [String] :payment_method_id Filter by payment method ID
      # @option args [String] :status Filter by status
      # @option args [String] :type Filter by type
      # @option args [String] :reference_id Filter by reference ID
      # @option args [String] :order_id Filter by order ID
      # @option args [String] :invoice_id Filter by invoice ID
      # @option args [String] :start_date Filter by start date (ISO 8601 format)
      # @option args [String] :end_date Filter by end date (ISO 8601 format)
      # @option args [Float] :min_amount Filter by minimum amount
      # @option args [Float] :max_amount Filter by maximum amount
      # @option args [Integer] :page Page number for pagination
      # @option args [Integer] :per_page Number of results per page
      # @return [Array<StaxPayments::Transaction>] Array of transaction objects
      def search_transactions(args = {})
        results = process_request(:post, '/transactions/search', body: args)
        return results if results.is_a?(StaxError)

        results[:transactions]&.map { |result| StaxPayments::Transaction.new(result) } || []
      end

      # Get transaction summary (aggregated data)
      # @param args [Hash] Filter parameters
      # @option args [String] :start_date Start date for summary (ISO 8601 format)
      # @option args [String] :end_date End date for summary (ISO 8601 format)
      # @option args [String] :group_by Group by parameter (e.g., 'day', 'week', 'month')
      # @return [Hash] Transaction summary data
      def transaction_summary(args = {})
        result = process_request(:get, '/transactions/summary', params: args)
        return result if result.is_a?(StaxError)

        result[:summary]
      end

      # Export transactions to a file (CSV or JSON)
      # @param args [Hash] Export parameters
      # @option args [String] :format Export format ('csv' or 'json')
      # @option args [String] :start_date Filter by start date (ISO 8601 format)
      # @option args [String] :end_date Filter by end date (ISO 8601 format)
      # @option args [String] :status Filter by status
      # @option args [String] :type Filter by type
      # @return [String] URL to download the exported file
      def export_transactions(args = {})
        result = process_request(:post, '/transactions/export', body: args)
        return result if result.is_a?(StaxError)

        result[:export_url]
      end

      # Email a transaction receipt
      # @param transaction_id [String] The ID of the transaction
      # @param args [Hash] Optional parameters
      # @option args [Array<String>] :cc_emails Additional email addresses to CC
      # @return [Boolean] Success status
      def email_transaction_receipt(transaction_id, args = {})
        result = process_request(:post, "/transactions/#{transaction_id}/email", body: args)
        return result if result.is_a?(StaxError)

        result[:success] == 1
      end

      # Send a transaction receipt via SMS
      # @param transaction_id [String] The ID of the transaction
      # @param args [Hash] Optional parameters
      # @option args [Array<String>] :cc_phones Additional phone numbers to CC
      # @return [Boolean] Success status
      def sms_transaction_receipt(transaction_id, args = {})
        result = process_request(:post, "/transactions/#{transaction_id}/sms", body: args)
        return result if result.is_a?(StaxError)

        result[:success] == 1
      end

      # Get a transaction's funding instructions
      # @param transaction_id [String] The ID of the transaction
      # @return [Array<Hash>] Funding instructions
      def transaction_funding(transaction_id)
        result = process_request(:get, "/transactions/#{transaction_id}/funding")
        return result if result.is_a?(StaxError)

        result[:funding]
      end

      # Capture a pre-authorized transaction
      # @param transaction_id [String] The ID of the pre-authorized transaction to capture
      # @param args [Hash] Optional parameters
      # @option args [Float] :total The amount to capture (must be less than or equal to the pre-auth amount)
      # @return [StaxPayments::Transaction] The captured transaction object
      # @example
      #   # Capture the full amount of a pre-authorized transaction
      #   transaction = client.capture_transaction('txn_123456789')
      #
      #   # Capture a partial amount of a pre-authorized transaction
      #   transaction = client.capture_transaction('txn_123456789', { total: 5.00 })
      def capture_transaction(transaction_id, args = {})
        result = process_request(:post, "/transaction/#{transaction_id}/capture", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Transaction.new(result)
      end

      # Void a transaction
      # @param transaction_id [String] The ID of the transaction to void
      # @return [StaxPayments::Transaction] The voided transaction object
      # @example
      #   # Void a transaction
      #   transaction = client.void_transaction('txn_123456789')
      #   puts "Transaction voided: #{transaction.is_voided}"
      def void_transaction(transaction_id)
        result = process_request(:post, "/transaction/#{transaction_id}/void")
        return result if result.is_a?(StaxError)

        StaxPayments::Transaction.new(result)
      end

      # Refund a transaction
      # @param transaction_id [String] The ID of the transaction to refund
      # @param args [Hash] Optional parameters
      # @option args [Float, String] :total (required) Amount to refund in dollars and cents
      # @return [StaxPayments::Transaction] The refunded transaction object
      # @example
      #   # Refund a transaction
      #   transaction = client.refund_transaction('txn_123456789', { total: 5.00 })
      #   puts "Transaction refunded: #{transaction.total_refunded}"
      #   puts "Child transactions: #{transaction.child_transactions.length}"
      def refund_transaction(transaction_id, args = {})
        # Validate that total is provided
        raise StaxPayments::StaxError.new('Total amount is required for refund') if args[:total].nil?

        result = process_request(:post, "/transaction/#{transaction_id}/refund", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Transaction.new(result)
      end
    end
  end
end
