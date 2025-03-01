# frozen_string_literal: true

module StaxPayments
  class Client
    module BankAccounts
      # List all bank accounts for a customer
      # @param customer_id [String] The ID of the customer
      # @param args [Hash] Optional parameters
      # @return [Array<StaxPayments::BankAccount>] Array of bank account objects
      def customer_bank_accounts(customer_id, args = {})
        results = process_request(:get, "customers/#{customer_id}/bank_accounts", params: args)
        return results if results.is_a?(StaxError)

        results[:bank_accounts]&.map { |result| StaxPayments::BankAccount.new(result) } || []
      end
      alias list_customer_bank_accounts customer_bank_accounts

      # Get a specific bank account
      # @param customer_id [String] The ID of the customer
      # @param bank_account_id [String] The ID of the bank account to retrieve
      # @return [StaxPayments::BankAccount] The bank account object
      def customer_bank_account(customer_id, bank_account_id)
        result = process_request(:get, "customers/#{customer_id}/bank_accounts/#{bank_account_id}")
        return result if result.is_a?(StaxError)

        StaxPayments::BankAccount.new(result[:bank_account])
      end
      alias get_customer_bank_account customer_bank_account

      # Create a new bank account for a customer
      # @param customer_id [String] The ID of the customer
      # @param args [Hash] Bank account details
      # @return [StaxPayments::BankAccount] The created bank account object
      def create_customer_bank_account(customer_id, args = {})
        result = process_request(:post, "customers/#{customer_id}/bank_accounts", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::BankAccount.new(result[:bank_account])
      end

      # Update a bank account
      # @param customer_id [String] The ID of the customer
      # @param bank_account_id [String] The ID of the bank account to update
      # @param args [Hash] Bank account details to update
      # @return [StaxPayments::BankAccount] The updated bank account object
      def update_customer_bank_account(customer_id, bank_account_id, args = {})
        result = process_request(:put, "customers/#{customer_id}/bank_accounts/#{bank_account_id}", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::BankAccount.new(result[:bank_account])
      end

      # Delete a bank account
      # @param customer_id [String] The ID of the customer
      # @param bank_account_id [String] The ID of the bank account to delete
      # @return [Boolean] True if successful
      def delete_customer_bank_account(customer_id, bank_account_id)
        result = process_request(:delete, "customers/#{customer_id}/bank_accounts/#{bank_account_id}")
        return result if result.is_a?(StaxError)

        result[:success] || false
      end

      # Verify a bank account
      # @param customer_id [String] The ID of the customer
      # @param bank_account_id [String] The ID of the bank account to verify
      # @param args [Hash] Verification details (e.g., amounts for micro-deposits)
      # @return [StaxPayments::BankAccount] The verified bank account object
      def verify_customer_bank_account(customer_id, bank_account_id, args = {})
        result = process_request(:post, "customers/#{customer_id}/bank_accounts/#{bank_account_id}/verify", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::BankAccount.new(result[:bank_account])
      end
    end
  end
end
