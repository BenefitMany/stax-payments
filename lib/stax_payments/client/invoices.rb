# frozen_string_literal: true

module StaxPayments
  class Client
    module Invoices
      # List all invoices with optional filtering and pagination
      # @param args [Hash] Optional parameters
      # @option args [Array<String>] :keywords Search keywords for filtering invoices
      # @option args [Integer] :page Page number for pagination
      # @option args [Integer] :limit Number of results per page
      # @option args [String] :schedule_id Filter by schedule ID
      # @option args [String] :payment_method Filter by payment method type ('card' or 'bank')
      # @option args [String] :status Filter by invoice status
      # @option args [String] :customer_id Filter by customer ID
      # @option args [String] :sort_by Field to sort by
      # @option args [String] :sort_dir Sort direction ('asc' or 'desc')
      # @return [Hash] Hash containing pagination information and invoice objects
      # @example
      #   # Basic pagination
      #   invoices = client.invoices(page: 1, limit: 25)
      #
      #   # Search by keywords
      #   invoices = client.invoices(keywords: ['Troy', 'Baker'])
      #
      #   # Filter by payment method
      #   invoices = client.invoices(payment_method: 'card')
      #
      #   # Filter by schedule ID
      #   invoices = client.invoices(schedule_id: 'e70c126c-f7b7-4673-a129-5b650f00f84a')
      def invoices(args = {})
        # Process keywords if provided
        if args[:keywords] && args[:keywords].is_a?(Array)
          args[:keywords] = args[:keywords].join(',')
        end

        results = process_request(:get, '/invoice', params: args)
        return results if results.is_a?(StaxError)

        # Process pagination data
        pagination = {
          total: results[:total],
          per_page: results[:per_page],
          current_page: results[:current_page],
          last_page: results[:last_page],
          next_page_url: results[:next_page_url],
          prev_page_url: results[:prev_page_url],
          from: results[:from],
          to: results[:to]
        }

        # Process invoice data
        invoices = results[:data]&.map { |result| StaxPayments::Invoice.new(result) } || []

        # Return both pagination info and invoices
        {
          pagination: pagination,
          invoices: invoices
        }
      end
      alias list_invoices invoices

      # Get a specific invoice by ID
      # @param invoice_id [String] The ID of the invoice to retrieve
      # @param args [Hash] Optional parameters
      # @option args [Array<String>] :keywords Search keywords for filtering related data
      # @return [StaxPayments::Invoice] The invoice object
      # @example
      #   # Basic invoice retrieval
      #   invoice = client.invoice('9ddcf02b-c2be-4f27-b758-dbc12b2aa924')
      #
      #   # With search keywords
      #   invoice = client.invoice('9ddcf02b-c2be-4f27-b758-dbc12b2aa924', keywords: ['Demo'])
      def invoice(invoice_id, args = {})
        # Process keywords if provided
        if args[:keywords] && args[:keywords].is_a?(Array)
          args[:keywords] = args[:keywords].join(',')
        end

        result = process_request(:get, "/invoice/#{invoice_id}", params: args)
        return result if result.is_a?(StaxError)

        # Handle the case where the API returns the invoice directly or nested in an 'invoice' key
        invoice_data = result[:invoice] || result
        StaxPayments::Invoice.new(invoice_data)
      end
      alias get_invoice invoice

      # Create a new invoice
      # @param args [Hash] Invoice details
      # @option args [String] :customer_id The ID of the customer to associate with the invoice
      # @option args [Hash] :meta Metadata about the invoice (required, max 60,000 characters)
      # @option args [Float, String] :total The total amount of the invoice
      # @option args [String] :url The URL for the invoice payment page (e.g., "https://app.staxpayments.com/#/bill/")
      # @option args [Boolean] :send_now Whether to send the invoice immediately
      # @option args [Boolean] :is_partial_payment_enabled Whether to allow partial payments
      # @option args [Array<String>] :files Array of file IDs to attach to the invoice
      # @option args [String] :invoice_date_at The date the work was done or service was provided
      # @return [StaxPayments::Invoice] The created invoice object
      # @example
      #   invoice = client.create_invoice({
      #     customer_id: 'd45ee88c-8b27-4be8-8d81-77dda1b81826',
      #     meta: {
      #       tax: 2,
      #       subtotal: 10,
      #       lineItems: [
      #         {
      #           item: 'Demo Item',
      #           details: 'this is a regular demo item',
      #           quantity: 10,
      #           price: 1
      #         }
      #       ],
      #       isCCPaymentEnabled: true,
      #       isACHPaymentEnabled: true,
      #       isTipEnabled: true,
      #       internalMemo: 'internalMemo',
      #       memo: 'customer facing memo'
      #     },
      #     total: '12.00',
      #     url: 'https://app.staxpayments.com/#/bill/',
      #     send_now: false,
      #     is_partial_payment_enabled: true
      #   })
      def create_invoice(args = {})
        # Validate required fields
        validate_invoice_params(args)

        result = process_request(:post, '/invoice', body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Invoice.new(result)
      end

      # Update an invoice
      # @param invoice_id [String] The ID of the invoice to update
      # @param args [Hash] Invoice details to update
      # @option args [String] :customer_id The ID of the customer to associate with the invoice
      # @option args [Hash] :meta Metadata about the invoice (max 60,000 characters)
      # @option args [Float, String] :total The total amount of the invoice
      # @option args [String] :payment_method_id The ID of the payment method to use
      # @option args [String] :url The URL for the invoice payment page
      # @option args [Array<String>] :files Array of file IDs to attach to the invoice
      # @option args [String] :invoice_date_at The date the work was done or service was provided
      # @option args [Boolean] :is_partial_payment_enabled Whether to allow partial payments
      # @return [StaxPayments::Invoice] The updated invoice object
      # @example
      #   updated_invoice = client.update_invoice('9ddcf02b-c2be-4f27-b758-dbc12b2aa924', {
      #     meta: {
      #       tax: 0,
      #       subtotal: 10,
      #       lineItems: [
      #         {
      #           id: "optional-fm-catalog-item-id",
      #           item: "Demo Item",
      #           details: "this is a regular demo item",
      #           quantity: 1,
      #           price: 100
      #         }
      #       ]
      #     },
      #     total: "100.00",
      #     payment_method_id: "d3050b19-77d9-44ac-9851-b1d1680a7684",
      #     url: "https://app.staxpayments.com/#/bill/"
      #   })
      def update_invoice(invoice_id, args = {})
        # Validate meta field length if provided
        if args[:meta] && args[:meta].to_json.length > 60000
          raise StaxError, 'The meta field should not contain more than 60,000 characters'
        end

        # Validate files if provided
        if args[:files] && !args[:files].is_a?(Array)
          raise StaxError, 'The files field must be an array'
        end

        result = process_request(:put, "/invoice/#{invoice_id}", body: args)
        return result if result.is_a?(StaxError)

        # Handle the case where the API returns the invoice directly or nested in an 'invoice' key
        invoice_data = result[:invoice] || result
        StaxPayments::Invoice.new(invoice_data)
      end

      # Delete an invoice
      # @param invoice_id [String] The ID of the invoice to delete
      # @return [StaxPayments::Invoice] The deleted invoice object
      # @example
      #   # Delete an invoice
      #   deleted_invoice = client.delete_invoice('9ddcf02b-c2be-4f27-b758-dbc12b2aa924')
      #
      #   # Check if the invoice is deleted
      #   puts deleted_invoice.deleted?  # => true
      #   puts deleted_invoice.status    # => "DELETED"
      def delete_invoice(invoice_id)
        result = process_request(:delete, "/invoice/#{invoice_id}")
        return result if result.is_a?(StaxError)

        StaxPayments::Invoice.new(result)
      end

      # Send an invoice
      # @param invoice_id [String] The ID of the invoice to send
      # @param args [Hash] Optional parameters (e.g., email)
      # @return [StaxPayments::Invoice] The sent invoice object
      def send_invoice(invoice_id, args = {})
        result = process_request(:post, "/invoice/#{invoice_id}/send", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Invoice.new(result[:invoice])
      end

      # Send an invoice via email
      # @param invoice_id [String] The ID of the invoice to send via email
      # @param args [Hash] Optional parameters
      # @option args [Array<String>] :cc_emails Array of email addresses to CC
      # @return [StaxPayments::Invoice] The sent invoice object
      # @example
      #   # Send an invoice with CC emails
      #   invoice = client.send_invoice_email('4bbd1a64-7472-44ed-afef-02b82d3eae24', {
      #     cc_emails: ['contactCC@example.com', 'contactCC2@example.com']
      #   })
      #
      #   # Check if the invoice was sent
      #   puts invoice.sent?  # => true
      #   puts invoice.status  # => "SENT"
      def send_invoice_email(invoice_id, args = {})
        # Validate cc_emails if provided
        if args[:cc_emails] && !args[:cc_emails].is_a?(Array)
          raise StaxError, 'The cc_emails field must be an array of email addresses'
        end

        result = process_request(:put, "/invoice/#{invoice_id}/send/email", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Invoice.new(result)
      end

      # Send an invoice via SMS
      # @param invoice_id [String] The ID of the invoice to send via SMS
      # @param args [Hash] Required and optional parameters
      # @option args [String] :phone Required. The phone number to send the SMS to
      # @option args [String] :message Optional. Custom message to include in the SMS
      # @return [StaxPayments::Invoice] The sent invoice object
      # @example
      #   # Send an invoice via SMS with a custom message
      #   invoice = client.send_invoice_sms('4bbd1a64-7472-44ed-afef-02b82d3eae24', {
      #     phone: '5555555555',
      #     message: 'Your invoice is ready for payment'
      #   })
      #
      #   # Send an invoice via SMS without a custom message
      #   invoice = client.send_invoice_sms('4bbd1a64-7472-44ed-afef-02b82d3eae24', {
      #     phone: '5555555555'
      #   })
      #
      #   # Check if the invoice was sent
      #   puts invoice.sent?  # => true
      #   puts invoice.status  # => "SENT"
      def send_invoice_sms(invoice_id, args = {})
        # Validate required phone parameter
        unless args[:phone]
          raise StaxError, 'The phone field is required'
        end

        # Validate phone format (basic validation)
        unless args[:phone].is_a?(String) && args[:phone].match?(/^\d{10,15}$/)
          raise StaxError, 'The phone field must be a string containing 10-15 digits'
        end

        result = process_request(:put, "/invoice/#{invoice_id}/send/sms", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Invoice.new(result)
      end

      # Pay an invoice
      # @param invoice_id [String] The ID of the invoice to pay
      # @param args [Hash] Payment details
      # @option args [Float] :apply_balance Optional. Default: invoice.total. If supplied, will create a partial payment for this invoice
      # @option args [Boolean] :email_receipt Optional. Default: false. If true, will send the invoice to the customer's email
      # @option args [String] :payment_method_id Optional. Override Payment Method. If supplied and valid, this will be used as the payment method
      # @option args [String] :idempotency_id Optional. A unique string identifier to help prevent against duplicate operations (max 255 characters)
      # @option args [Hash] :meta Optional. Additional metadata for the payment
      # @option args [Array] :funding Optional. Defines how funds should be paid out (requires Split Funding feature)
      # @return [StaxPayments::Invoice] The paid invoice object
      # @example
      #   invoice = client.pay_invoice('990117ce-b31f-4e76-b027-52e90b32e465', {
      #     payment_method_id: 'f27192f5-c170-451c-a45e-397acb870b15',
      #     email_receipt: true,
      #     apply_balance: 10
      #   })
      def pay_invoice(invoice_id, args = {})
        # Validate payment parameters
        validate_payment_params(args)

        result = process_request(:post, "/invoice/#{invoice_id}/pay", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Invoice.new(result)
      end

      private

      # Validate invoice parameters
      # @param args [Hash] Invoice parameters to validate
      # @raise [StaxError] If any required parameters are missing or invalid
      def validate_invoice_params(args)
        # Check required fields
        unless args[:meta]
          raise StaxError, 'The meta field is required'
        end

        unless args[:total]
          raise StaxError, 'The total field is required'
        end

        unless args[:url]
          raise StaxError, 'The url field is required'
        end

        # Validate meta field length
        if args[:meta].to_json.length > 60000
          raise StaxError, 'The meta field should not contain more than 60,000 characters'
        end

        # Validate files if provided
        if args[:files] && !args[:files].is_a?(Array)
          raise StaxError, 'The files field must be an array'
        end
      end

      # Validate payment parameters
      # @param args [Hash] Payment parameters to validate
      # @raise [StaxError] If any parameters are invalid
      def validate_payment_params(args)
        # Validate apply_balance is a number if provided
        if args.key?(:apply_balance) && !args[:apply_balance].is_a?(Numeric) && args[:apply_balance].to_s !~ /\A\d+(\.\d+)?\z/
          raise StaxError, 'The apply_balance must be a number'
        end

        # Validate email_receipt is a boolean if provided
        if args.key?(:email_receipt) && ![true, false].include?(args[:email_receipt])
          raise StaxError, 'The email_receipt field must be true or false'
        end

        # Validate idempotency_id length if provided
        if args[:idempotency_id] && args[:idempotency_id].to_s.length > 255
          raise StaxError, 'The idempotency_id must not exceed 255 characters'
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

        # Validate meta transaction types if provided
        if args[:meta]
          if args[:meta][:transaction_initiation_type] && !%w[MIT CIT].include?(args[:meta][:transaction_initiation_type])
            raise StaxError, 'The transaction_initiation_type must be either MIT or CIT'
          end

          if args[:meta][:transaction_schedule_type] && !%w[scheduled unscheduled].include?(args[:meta][:transaction_schedule_type])
            raise StaxError, 'The transaction_schedule_type must be either scheduled or unscheduled'
          end
        end
      end
    end
  end
end
