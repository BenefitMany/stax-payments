# frozen_string_literal: true

module StaxPayments
  class Client
    module PaymentMethods
      # List all payment methods for a merchant with filtering options
      # @param args [Hash] Optional parameters
      # @option args [Integer] :per_page Number of results per page (default: 20, max: 200)
      # @option args [Integer] :page Page number for pagination
      # @option args [String] :au_last_event Filter by account updater last event ('ReplacePaymentMethod', 'ContactCardHolder', 'ClosePaymentMethod')
      # @option args [String] :au_last_event_start_at Filter by account updater events after this date (format: 'yyyy-mm-dd hh:mm:ss')
      # @option args [String] :au_last_event_end_at Filter by account updater events before this date (format: 'yyyy-mm-dd hh:mm:ss')
      # @option args [String] :status Filter by status ('all' for both active and deleted, 'deleted' for only deleted)
      # @return [Hash] Hash containing pagination info and array of payment method objects
      # @example
      #   # List all payment methods with default pagination
      #   result = client.payment_methods
      #   payment_methods = result[:payment_methods]
      #   puts "Found #{payment_methods.size} payment methods"
      #
      #   # List payment methods with filtering
      #   result = client.payment_methods(
      #     per_page: 50,
      #     au_last_event: 'ReplacePaymentMethod',
      #     au_last_event_start_at: '2023-01-01 00:00:00'
      #   )
      def payment_methods(args = {})
        # Validate per_page if provided
        if args[:per_page]
          args[:per_page] = args[:per_page].to_i
          if args[:per_page] < 1 || args[:per_page] > 200
            raise StaxError, 'per_page must be between 1 and 200'
          end
        end

        # Validate au_last_event if provided
        if args[:au_last_event] && !%w[ReplacePaymentMethod ContactCardHolder ClosePaymentMethod].include?(args[:au_last_event])
          raise StaxError, 'au_last_event must be one of: ReplacePaymentMethod, ContactCardHolder, ClosePaymentMethod'
        end

        # Validate date formats if provided
        date_format = /\A\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\z/
        if args[:au_last_event_start_at] && args[:au_last_event_start_at] !~ date_format
          raise StaxError, 'au_last_event_start_at must be in the format: yyyy-mm-dd hh:mm:ss'
        end

        if args[:au_last_event_end_at] && args[:au_last_event_end_at] !~ date_format
          raise StaxError, 'au_last_event_end_at must be in the format: yyyy-mm-dd hh:mm:ss'
        end

        # Validate status if provided
        if args[:status] && !%w[all deleted].include?(args[:status])
          raise StaxError, 'status must be one of: all, deleted'
        end

        results = process_request(:get, 'payment-method', params: args)
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

        # Process payment method data
        payment_methods = results[:data]&.map { |result| StaxPayments::PaymentMethod.new(result) } || []

        # Return both pagination info and payment methods
        {
          pagination: pagination,
          payment_methods: payment_methods
        }
      end
      alias list_payment_methods payment_methods

      # Get a specific payment method by ID
      # @param payment_method_id [String] The ID of the payment method to retrieve
      # @return [StaxPayments::PaymentMethod, StaxError] The payment method object or an error
      # @example
      #   payment_method = client.payment_method('7e3a83ea-6770-41f7-9b28-7ea1a3ae33e7')
      #   puts payment_method.nickname # => "VISA: Bob Smithers (ending in: 1111)"
      #   puts payment_method.card_type # => "visa"
      #   puts payment_method.card_last_four # => "1111"
      def payment_method(payment_method_id)
        result = process_request(:get, "payment-method/#{payment_method_id}")

        # Handle 404 errors specifically for payment method not found
        if result.is_a?(StaxError) && result.response && result.response.code == 404
          return StaxError.new("Payment method not found: #{payment_method_id}")
        end

        # Handle other errors
        return result if result.is_a?(StaxError)

        # If we have a payment_method property, use that, otherwise use the entire result
        payment_method_data = result[:payment_method] || result
        StaxPayments::PaymentMethod.new(payment_method_data)
      end
      alias get_payment_method payment_method

      # List all payment methods for a specific customer
      # @param customer_id [String] The ID of the customer
      # @param args [Hash] Optional parameters (same as payment_methods method)
      # @return [Array<StaxPayments::PaymentMethod>] Array of payment method objects
      # @example
      #   payment_methods = client.customer_payment_methods('35e4cfa9-d87e-45fc-84da-a6bdce2c3330')
      #   puts "Found #{payment_methods.size} payment methods for customer"
      #   payment_methods.each do |pm|
      #     puts "#{pm.nickname} (#{pm.method})"
      #   end
      def customer_payment_methods(customer_id, args = {})
        # Use the dedicated endpoint for customer payment methods
        result = process_request(:get, "customer/#{customer_id}/payment-method", params: args)
        return result if result.is_a?(StaxError)

        # The API returns an array of payment methods directly
        result.map { |pm_data| StaxPayments::PaymentMethod.new(pm_data) }
      end

      # Delete a payment method
      # @param payment_method_id [String] The ID of the payment method to delete
      # @return [StaxPayments::PaymentMethod] The deleted payment method object
      # @example
      #   payment_method = client.delete_payment_method('7e3a83ea-6770-41f7-9b28-7ea1a3ae33e7')
      #   puts "Payment method deleted: #{payment_method.id}"
      #   puts "Deleted at: #{payment_method.deleted_at}"
      def delete_payment_method(payment_method_id)
        result = process_request(:delete, "payment-method/#{payment_method_id}")
        return result if result.is_a?(StaxError)

        StaxPayments::PaymentMethod.new(result)
      end

      # Create a new payment method
      # @param args [Hash] Payment method details
      # @option args [String] :customer_id (required) The ID of the customer to associate with this payment method
      # @option args [String] :method (required) The type of payment method ('card' or 'bank')
      # @option args [String] :person_name (required) Account holder first and last name (must include 2 names separated by a space)
      # @option args [String] :card_number (required for cards) The card number
      # @option args [String] :card_cvv (optional for cards) The card CVV
      # @option args [String] :card_exp (required for cards) 4 digit expiration (e.g., "0427" for April 2027)
      # @option args [String] :card_type (optional for cards) The type of card
      # @option args [String] :bank_account (required for bank accounts) The bank account number
      # @option args [String] :bank_routing (required for bank accounts) The bank routing number
      # @option args [String] :bank_name (required for bank accounts) The name of the bank
      # @option args [String] :bank_type (required for bank accounts) The type of bank account ('checking' or 'savings')
      # @option args [String] :bank_holder_type (required for bank accounts) The type of account holder ('personal' or 'business')
      # @option args [Boolean] :is_default Whether this is the default payment method for the customer
      # @option args [String] :address_1 The first line of the billing address (may be used for AVS)
      # @option args [String] :address_2 The second line of the billing address
      # @option args [String] :address_city The city of the billing address
      # @option args [String] :address_state The state of the billing address (2 characters)
      # @option args [String] :address_zip The postal code of the billing address (may be used for AVS)
      # @option args [String] :address_country The country of the billing address (3 characters)
      # @return [StaxPayments::PaymentMethod] The created payment method object
      # @example
      #   # Create a card payment method
      #   payment_method = client.create_payment_method({
      #     customer_id: 'ed641b85-afa2-4413-9f30-b37aa719aeaf',
      #     method: 'card',
      #     person_name: 'Steven Smith',
      #     card_number: '4111111111111111',
      #     card_cvv: '123',
      #     card_exp: '0427'
      #   })
      #
      #   # Create a bank account payment method
      #   payment_method = client.create_payment_method({
      #     customer_id: 'ed641b85-afa2-4413-9f30-b37aa719aeaf',
      #     method: 'bank',
      #     person_name: 'Steven Smith',
      #     bank_account: '123456789',
      #     bank_routing: '123456789',
      #     bank_name: 'Test Bank',
      #     bank_type: 'checking',
      #     bank_holder_type: 'personal'
      #   })
      def create_payment_method(args = {})
        # Validate required fields
        validate_payment_method_params(args)

        result = process_request(:post, 'payment-method', body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::PaymentMethod.new(result)
      end

      # Update an existing payment method
      # @param payment_method_id [String] The ID of the payment method to update
      # @param args [Hash] Payment method details to update
      # @option args [Boolean] :is_default Whether this is the default payment method for the customer
      # @option args [String] :person_name Account holder first and last name (must include 2 names separated by a space if provided)
      # @option args [String] :card_last_four The last four digits of the card number (max: 9999)
      # @option args [String] :card_type The type of card
      # @option args [String] :card_exp 4 digit expiration (e.g., "0427" for April 2027)
      # @option args [Boolean] :has_cvv Whether the payment method has a CVV stored
      # @option args [String] :bank_name The name of the bank
      # @option args [String] :bank_type The type of bank account ('checking' or 'savings')
      # @option args [String] :bank_holder_type The type of account holder ('personal' or 'business')
      # @option args [Hash] :meta Additional metadata about the payment method (will overwrite the entire meta object if supplied)
      # @option args [String] :address_1 The first line of the billing address (may be used for AVS)
      # @option args [String] :address_2 The second line of the billing address
      # @option args [String] :address_city The city of the billing address
      # @option args [String] :address_state The state of the billing address (2 characters)
      # @option args [String] :address_zip The postal code of the billing address (may be used for AVS)
      # @option args [String] :address_country The country of the billing address (3 characters)
      # @return [StaxPayments::PaymentMethod] The updated payment method object
      # @example
      #   # Update a payment method
      #   payment_method = client.update_payment_method('6ba7babe-9906-4e7e-b1a5-f628c7badb61', {
      #     is_default: 1,
      #     person_name: 'Carl Junior Sr.',
      #     card_type: 'visa',
      #     card_last_four: '1111',
      #     card_exp: '032020',
      #     address_zip: '32944',
      #     address_country: 'USA'
      #   })
      def update_payment_method(payment_method_id, args = {})
        # Validate update parameters
        validate_update_payment_method_params(args)

        result = process_request(:put, "payment-method/#{payment_method_id}", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::PaymentMethod.new(result)
      end

      # Share a payment method with a third party
      # @param payment_method_id [String] The ID of the payment method to share
      # @param gateway_token [String] The third party gateway token
      # @return [Hash] The response containing the transaction details
      # @example
      #   # Share a payment method with a third party
      #   result = client.share_payment_method('6ba7babe-9906-4e7e-b1a5-f628c7badb61', '237c78vnYCN201Ib0ZAEzlZ4d0l')
      #   if result.is_a?(StaxError)
      #     puts "Error sharing payment method: #{result.message}"
      #   else
      #     puts "Payment method shared successfully!"
      #     puts "Transaction token: #{result['0']['transaction']['token']}"
      #     puts "Third party token: #{result['0']['transaction']['payment_method']['third_party_token']}"
      #   end
      def share_payment_method(payment_method_id, gateway_token)
        # Validate required parameters
        if gateway_token.nil? || gateway_token.empty?
          raise StaxError, 'The gateway_token is required'
        end

        result = process_request(:post, "payment_method/#{payment_method_id}/external_vault", body: { gateway_token: gateway_token })
        return result if result.is_a?(StaxError)

        result
      end

      # Review a transaction's surcharge information
      # @param payment_method_id [String] The ID of the payment method to check
      # @param total [Float, String] The transaction subtotal
      # @return [Hash] The surcharge information including bin_type, surcharge_rate, surcharge_amount, and total_with_surcharge_amount
      # @example
      #   # Review surcharge for a transaction
      #   surcharge_info = client.review_surcharge('6ba7babe-9906-4e7e-b1a5-f628c7badb61', 12.00)
      #   puts "Bin Type: #{surcharge_info[:bin_type]}"
      #   puts "Surcharge Rate: #{surcharge_info[:surcharge_rate]}%"
      #   puts "Surcharge Amount: $#{surcharge_info[:surcharge_amount]}"
      #   puts "Total with Surcharge: $#{surcharge_info[:total_with_surcharge_amount]}"
      def review_surcharge(payment_method_id, total)
        # Validate required parameters
        if payment_method_id.nil? || payment_method_id.empty?
          raise StaxError, 'The payment_method_id is required'
        end

        if total.nil?
          raise StaxError, 'The total is required'
        end

        # Validate total is a positive number
        if total.to_f <= 0
          raise StaxError, 'The total must be greater than 0'
        end

        result = process_request(:get, 'surcharge/review', params: { payment_method_id: payment_method_id, total: total })
        return result if result.is_a?(StaxError)

        result
      end

      private

      # Validate payment method parameters
      # @param args [Hash] Payment method parameters to validate
      # @raise [StaxError] If any required parameters are missing or invalid
      def validate_payment_method_params(args)
        # Check required fields for all payment methods
        unless args[:customer_id]
          raise StaxError, 'The customer_id field is required'
        end

        unless args[:method]
          raise StaxError, 'The method field is required'
        end

        unless %w[card bank].include?(args[:method])
          raise StaxError, "The method must be 'card' or 'bank'"
        end

        unless args[:person_name]
          raise StaxError, 'The person_name field is required'
        end

        # Validate person_name format (must include first and last name)
        name_parts = args[:person_name].to_s.split(' ')
        if name_parts.length < 2 || name_parts[0].empty? || name_parts[1].empty?
          raise StaxError, 'The person_name must include first and last name separated by a space'
        end

        # Check required fields for card payment methods
        if args[:method] == 'card'
          unless args[:card_number]
            raise StaxError, 'The card_number field is required for card payment methods'
          end

          unless args[:card_exp]
            raise StaxError, 'The card_exp field is required for card payment methods'
          end

          # Validate card_exp format (must be 4 digits)
          unless args[:card_exp].to_s =~ /^\d{4}$/
            raise StaxError, 'The card_exp must be 4 digits (e.g., "0427" for April 2027)'
          end
        end

        # Check required fields for bank payment methods
        if args[:method] == 'bank'
          unless args[:bank_account]
            raise StaxError, 'The bank_account field is required for bank payment methods'
          end

          unless args[:bank_routing]
            raise StaxError, 'The bank_routing field is required for bank payment methods'
          end

          unless args[:bank_name]
            raise StaxError, 'The bank_name field is required for bank payment methods'
          end

          unless args[:bank_type]
            raise StaxError, 'The bank_type field is required for bank payment methods'
          end

          unless %w[checking savings].include?(args[:bank_type])
            raise StaxError, "The bank_type must be 'checking' or 'savings'"
          end

          unless args[:bank_holder_type]
            raise StaxError, 'The bank_holder_type field is required for bank payment methods'
          end

          unless %w[personal business].include?(args[:bank_holder_type])
            raise StaxError, "The bank_holder_type must be 'personal' or 'business'"
          end
        end

        # Validate address_state if provided (must be 2 characters)
        if args[:address_state] && args[:address_state].length != 2
          raise StaxError, 'The address_state must be 2 characters'
        end

        # Validate address_country if provided (must be 3 characters)
        if args[:address_country] && args[:address_country].length != 3
          raise StaxError, 'The address_country must be 3 characters'
        end
      end

      # Validate update payment method parameters
      # @param args [Hash] Payment method update parameters to validate
      # @raise [StaxError] If any parameters are invalid
      def validate_update_payment_method_params(args)
        # Validate person_name format if provided (must include first and last name)
        if args[:person_name]
          name_parts = args[:person_name].to_s.split(' ')
          if name_parts.length < 2 || name_parts[0].empty? || name_parts[1].empty?
            raise StaxError, 'The person_name must include first and last name separated by a space'
          end
        end

        # Validate card_last_four if provided (must be numeric and max 4 digits)
        if args[:card_last_four]
          unless args[:card_last_four].to_s =~ /^\d{1,4}$/
            raise StaxError, 'The card_last_four must be numeric and maximum 4 digits'
          end
        end

        # Validate card_exp format if provided (must be 4 digits)
        if args[:card_exp]
          unless args[:card_exp].to_s =~ /^\d{4}$/
            raise StaxError, 'The card_exp must be 4 digits (e.g., "0427" for April 2027)'
          end
        end

        # Validate bank_type if provided
        if args[:bank_type]
          unless %w[checking savings].include?(args[:bank_type])
            raise StaxError, "The bank_type must be 'checking' or 'savings'"
          end
        end

        # Validate bank_holder_type if provided
        if args[:bank_holder_type]
          unless %w[personal business].include?(args[:bank_holder_type])
            raise StaxError, "The bank_holder_type must be 'personal' or 'business'"
          end
        end

        # Validate address_state if provided (must be 2 characters)
        if args[:address_state] && args[:address_state].length != 2
          raise StaxError, 'The address_state must be 2 characters'
        end

        # Validate address_country if provided (must be 3 characters)
        if args[:address_country] && args[:address_country].length != 3
          raise StaxError, 'The address_country must be 3 characters'
        end
      end
    end
  end
end