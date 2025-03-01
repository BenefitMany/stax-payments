# frozen_string_literal: true

module StaxPayments
  class BankAccount < StaxModel
    # Common bank account attributes:
    # - id: The unique identifier for the bank account
    # - customer_id: The ID of the customer associated with the bank account
    # - account_type: The type of account (e.g., checking, savings)
    # - account_number_last4: The last 4 digits of the account number
    # - routing_number: The routing number of the bank
    # - bank_name: The name of the bank
    # - account_holder_name: The name of the account holder
    # - status: The status of the bank account (e.g., new, verified, failed)
    # - is_default: Whether this is the default bank account for the customer
    # - created_at: When the bank account was created
    # - updated_at: When the bank account was last updated
  end
end
