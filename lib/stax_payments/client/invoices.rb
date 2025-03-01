# frozen_string_literal: true

module StaxPayments
  class Client
    module Invoices
      # List all invoices
      # @param args [Hash] Optional parameters
      # @return [Array<StaxPayments::Invoice>] Array of invoice objects
      def invoices(args = {})
        results = process_request(:get, 'invoices', params: args)
        return results if results.is_a?(StaxError)

        results[:invoices]&.map { |result| StaxPayments::Invoice.new(result) } || []
      end
      alias list_invoices invoices

      # Get a specific invoice
      # @param invoice_id [String] The ID of the invoice to retrieve
      # @return [StaxPayments::Invoice] The invoice object
      def invoice(invoice_id)
        result = process_request(:get, "invoices/#{invoice_id}")
        return result if result.is_a?(StaxError)

        StaxPayments::Invoice.new(result[:invoice])
      end
      alias get_invoice invoice

      # Create a new invoice
      # @param args [Hash] Invoice details
      # @return [StaxPayments::Invoice] The created invoice object
      def create_invoice(args = {})
        result = process_request(:post, 'invoices', body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Invoice.new(result[:invoice])
      end

      # Update an invoice
      # @param invoice_id [String] The ID of the invoice to update
      # @param args [Hash] Invoice details to update
      # @return [StaxPayments::Invoice] The updated invoice object
      def update_invoice(invoice_id, args = {})
        result = process_request(:put, "invoices/#{invoice_id}", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Invoice.new(result[:invoice])
      end

      # Delete an invoice
      # @param invoice_id [String] The ID of the invoice to delete
      # @return [Boolean] True if successful
      def delete_invoice(invoice_id)
        result = process_request(:delete, "invoices/#{invoice_id}")
        return result if result.is_a?(StaxError)

        result[:success] || false
      end

      # Send an invoice
      # @param invoice_id [String] The ID of the invoice to send
      # @param args [Hash] Optional parameters (e.g., email)
      # @return [StaxPayments::Invoice] The sent invoice object
      def send_invoice(invoice_id, args = {})
        result = process_request(:post, "invoices/#{invoice_id}/send", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Invoice.new(result[:invoice])
      end

      # Pay an invoice
      # @param invoice_id [String] The ID of the invoice to pay
      # @param args [Hash] Payment details
      # @return [StaxPayments::Payment] The payment object
      def pay_invoice(invoice_id, args = {})
        result = process_request(:post, "invoices/#{invoice_id}/pay", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Payment.new(result[:payment])
      end
    end
  end
end
