# frozen_string_literal: true

module StaxPayments
  class Client
    module Customers
      # List all customers
      # @param args [Hash] Optional parameters
      # @return [Array<StaxPayments::Customer>] Array of customer objects
      def customers(args = {})
        results = process_request(:get, 'customers', params: args)
        return results if results.is_a?(StaxError)

        results[:customers]&.map { |result| StaxPayments::Customer.new(result) } || []
      end
      alias list_customers customers

      # Get a specific customer
      # @param customer_id [String] The ID of the customer to retrieve
      # @return [StaxPayments::Customer] The customer object
      def customer(customer_id)
        result = process_request(:get, "customers/#{customer_id}")
        return result if result.is_a?(StaxError)

        StaxPayments::Customer.new(result[:customer])
      end
      alias get_customer customer

      # Create a new customer
      # @param args [Hash] Customer details
      # @return [StaxPayments::Customer] The created customer object
      def create_customer(args = {})
        result = process_request(:post, 'customers', body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Customer.new(result[:customer])
      end

      # Update an existing customer
      # @param customer_id [String] The ID of the customer to update
      # @param args [Hash] Customer details to update
      # @return [StaxPayments::Customer] The updated customer object
      def update_customer(customer_id, args = {})
        result = process_request(:put, "customers/#{customer_id}", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Customer.new(result[:customer])
      end

      # Delete a customer
      # @param customer_id [String] The ID of the customer to delete
      # @return [Boolean] True if successful
      def delete_customer(customer_id)
        result = process_request(:delete, "customers/#{customer_id}")
        return result if result.is_a?(StaxError)

        result[:success] || false
      end
    end
  end
end
