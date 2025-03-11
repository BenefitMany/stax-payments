# frozen_string_literal: true

module StaxPayments
  class Client
    module Customers
      # List all customers with filtering and sorting options
      # @param args [Hash] Optional parameters
      # @option args [String] :firstname Filter customers by first name (partial match)
      # @option args [String] :lastname Filter customers by last name (partial match)
      # @option args [String] :company Filter customers by company name (partial match)
      # @option args [String] :phone Filter customers by phone number (partial match, empty string for no phone)
      # @option args [String] :email Filter customers by email (partial match)
      # @option args [String] :address_1 Filter customers by address line 1 (partial match)
      # @option args [String] :address_2 Filter customers by address line 2 (partial match)
      # @option args [String] :address_city Filter customers by city (partial match)
      # @option args [String] :address_state Filter customers by state (2 characters only)
      # @option args [String] :address_zip Filter customers by zip code (partial match)
      # @option args [String] :reference Filter customers by reference (partial match)
      # @option args [Array<String>] :keywords Search across multiple fields (id, firstname, lastname, email, company, notes, reference, phone)
      # @option args [String] :order Sort order ('asc' or 'desc')
      # @option args [String] :sort_by Field to sort by (firstname, lastname, email, company, address_1, address_city, address_state, reference, created_at, updated_at)
      # @option args [Integer] :page Page number for pagination
      # @option args [Integer] :per_page Number of results per page
      # @return [Hash] Hash containing pagination info and array of customer objects
      def customers(args = {})
        # Handle sorting parameters
        if args[:sort_by]
          valid_sort_fields = %w[firstname lastname email company address_1 address_city address_state reference created_at updated_at]
          unless valid_sort_fields.include?(args[:sort_by])
            raise StaxError, "Invalid sort field. Must be one of: #{valid_sort_fields.join(', ')}"
          end

          # Convert sort_by to the API's expected format
          args[:sort] = args.delete(:sort_by)
        end

        # Validate state format if provided
        if args[:address_state] && args[:address_state].length != 2
          raise StaxError, 'State must be 2 characters'
        end

        results = process_request(:get, '/customer', params: args)
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

        # Process customer data
        customers = results[:data]&.map { |result| StaxPayments::Customer.new(result) } || []

        # Return both pagination info and customers
        {
          pagination: pagination,
          customers: customers
        }
      end
      alias list_customers customers

      # Get a specific customer by ID
      # @param customer_id [String] The ID of the customer to retrieve
      # @return [StaxPayments::Customer, StaxError] The customer object or an error
      # @example
      #   customer = client.customer('d45ee88c-8b27-4be8-8d81-77dda1b81826')
      #   puts customer.firstname # => "John"
      #   puts customer.lastname # => "Smith"
      #   puts customer.email # => "contact@example.com"
      # @example Error handling
      #   customer = client.customer('invalid_id')
      #   if customer.is_a?(StaxError)
      #     puts "Error: #{customer.message}" # => "Error: customer not found"
      #   end
      def customer(customer_id)
        result = process_request(:get, "/customer/#{customer_id}")

        # Handle 404 errors specifically for customer not found
        if result.is_a?(StaxError) && result.response && result.response.code == 404
          return StaxError.new("Customer not found: #{customer_id}")
        end

        # Handle other errors
        return result if result.is_a?(StaxError)

        # If we have a customer property, use that, otherwise use the entire result
        # This handles both the documented response format and potential variations
        customer_data = result[:customer] || result
        StaxPayments::Customer.new(customer_data)
      end
      alias get_customer customer

      # Create a new customer
      # @param args [Hash] Customer details
      # @option args [String] :firstname Customer's first name (required if no lastname, email, company supplied)
      # @option args [String] :lastname Customer's last name (required if no firstname, email, company supplied)
      # @option args [String] :email Customer's email address (required if no firstname, lastname, company supplied)
      # @option args [String] :company Customer's company name (required if no firstname, lastname, email supplied)
      # @option args [String] :phone Customer's phone number (matching regex: /[0-9]{10,15}/)
      # @option args [String] :address_1 Customer's address line 1
      # @option args [String] :address_2 Customer's address line 2
      # @option args [String] :address_city Customer's city
      # @option args [String] :address_state Customer's state (2 characters)
      # @option args [String] :address_zip Customer's postal code (up to 16 characters)
      # @option args [String] :address_country Customer's country (3 characters)
      # @option args [String] :notes Additional notes about the customer (not visible to customer)
      # @option args [String] :reference A merchant-defined reference string
      # @option args [Array<String>] :cc_emails Array of email addresses to CC on communications
      # @option args [Array<String>] :cc_sms Array of phone numbers to CC on SMS communications
      # @option args [Boolean] :allow_invoice_credit_card_payments Whether to allow credit card payments for invoices
      # @return [StaxPayments::Customer] The created customer object
      def create_customer(args = {})
        # Validate required fields
        unless args[:firstname] || args[:lastname] || args[:email] || args[:company]
          raise StaxError, 'At least one of firstname, lastname, email, or company must be provided'
        end

        # Validate phone number format if provided
        if args[:phone] && args[:phone] !~ /[0-9]{10,15}/
          raise StaxError, 'Phone number must be 10-15 digits'
        end

        # Validate email format if provided
        if args[:email] && args[:email] !~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
          raise StaxError, 'Email must be a valid email address'
        end

        # Validate state format if provided
        if args[:address_state] && args[:address_state].length != 2
          raise StaxError, 'State must be 2 characters'
        end

        # Validate country format if provided
        if args[:address_country] && args[:address_country].length != 3
          raise StaxError, 'Country must be 3 characters'
        end

        result = process_request(:post, '/customer', body: args)
        puts result
        return result if result.is_a?(StaxError)

        StaxPayments::Customer.new(result)
      end

      # Update an existing customer's information
      # @param customer_id [String] The ID of the customer to update
      # @param args [Hash] Customer details to update
      # @option args [String] :firstname Customer's first name (required if no lastname, email, company supplied)
      # @option args [String] :lastname Customer's last name (required if no firstname, email, company supplied)
      # @option args [String] :email Customer's email address (required if no firstname, lastname, company supplied)
      # @option args [String] :company Customer's company name (required if no firstname, lastname, email supplied)
      # @option args [String] :phone Customer's phone number (matching regex: /[0-9]{10,15}/)
      # @option args [String] :address_1 Customer's address line 1
      # @option args [String] :address_2 Customer's address line 2
      # @option args [String] :address_city Customer's city
      # @option args [String] :address_state Customer's state (2 characters)
      # @option args [String] :address_zip Customer's postal code (up to 16 characters)
      # @option args [String] :address_country Customer's country (3 characters)
      # @option args [String] :notes Additional notes about the customer (not visible to customer)
      # @option args [String] :reference A merchant-defined reference string
      # @option args [Array<String>] :cc_emails Array of email addresses to CC on communications
      # @option args [Array<String>] :cc_sms Array of phone numbers to CC on SMS communications
      # @option args [Boolean] :allow_invoice_credit_card_payments Whether to allow credit card payments for invoices
      # @return [StaxPayments::Customer, StaxError] The updated customer object or an error
      # @example
      #   customer = client.update_customer('d45ee88c-8b27-4be8-8d81-77dda1b81826', {
      #     firstname: 'Jane',
      #     lastname: 'Doe',
      #     email: 'jane.doe@example.com'
      #   })
      #   puts customer.firstname # => "Jane"
      # @example Error handling
      #   customer = client.update_customer('invalid_id', { firstname: 'Jane' })
      #   if customer.is_a?(StaxError)
      #     puts "Error: #{customer.message}" # => "Error: customer not found"
      #   end
      def update_customer(customer_id, args = {})
        # Validate phone number format if provided
        if args[:phone] && args[:phone] !~ /[0-9]{10,15}/
          raise StaxError, 'Phone number must be 10-15 digits'
        end

        # Validate email format if provided
        if args[:email] && args[:email] !~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
          raise StaxError, 'Email must be a valid email address'
        end

        # Validate state format if provided
        if args[:address_state] && args[:address_state].length != 2
          raise StaxError, 'State must be 2 characters'
        end

        # Validate country format if provided
        if args[:address_country] && args[:address_country].length != 3
          raise StaxError, 'Country must be 3 characters'
        end

        # Validate cc_emails format if provided
        if args[:cc_emails] && !args[:cc_emails].is_a?(Array)
          raise StaxError, 'cc_emails must be an array of email addresses'
        end

        # Validate cc_sms format if provided
        if args[:cc_sms] && !args[:cc_sms].is_a?(Array)
          raise StaxError, 'cc_sms must be an array of phone numbers'
        end

        result = process_request(:put, "/customer/#{customer_id}", body: args)

        # Handle 404 errors specifically for customer not found
        if result.is_a?(StaxError) && result.response && result.response.code == 404
          return StaxError.new("Customer not found: #{customer_id}")
        end

        # Handle other errors
        return result if result.is_a?(StaxError)

        # If we have a customer property, use that, otherwise use the entire result
        customer_data = result[:customer] || result
        StaxPayments::Customer.new(customer_data)
      end

      # Delete a customer
      # @param customer_id [String] The ID of the customer to delete
      # @return [Boolean] True if successful
      def delete_customer(customer_id)
        result = process_request(:delete, "/customer/#{customer_id}")
        return result if result.is_a?(StaxError)

        result[:success] || false
      end
    end
  end
end
