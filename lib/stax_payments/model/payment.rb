# frozen_string_literal: true

module StaxPayments
  class Payment < StaxModel
    # Common payment attributes:
    # - id: The unique identifier for the payment
    # - amount: The payment amount
    # - currency: The payment currency (e.g., USD)
    # - status: The payment status (e.g., pending, completed, failed)
    # - customer_id: The ID of the customer associated with the payment
    # - payment_method_id: The ID of the payment method used
    # - payment_method_type: The type of payment method (e.g., card, bank_account)
    # - description: A description of the payment
    # - metadata: Additional metadata about the payment
    # - created_at: When the payment was created
    # - updated_at: When the payment was last updated
  end
end
