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
        results = process_request(:get, 'transactions', params: args)
        return results if results.is_a?(StaxError)

        results[:transactions]&.map { |result| StaxPayments::Transaction.new(result) } || []
      end
      alias list_transactions transactions

      # Get a specific transaction
      # @param transaction_id [String] The ID of the transaction to retrieve
      # @return [StaxPayments::Transaction] The transaction object
      def transaction(transaction_id)
        result = process_request(:get, "transactions/#{transaction_id}")
        return result if result.is_a?(StaxError)

        StaxPayments::Transaction.new(result[:transaction])
      end
      alias get_transaction transaction

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
        results = process_request(:post, 'transactions/search', body: args)
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
        result = process_request(:get, 'transactions/summary', params: args)
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
        result = process_request(:post, 'transactions/export', body: args)
        return result if result.is_a?(StaxError)

        result[:export_url]
      end
    end
  end
end
