# frozen_string_literal: true

module StaxPayments
  class Refund < StaxModel
    # Common refund attributes:
    # - id: The unique identifier for the refund
    # - amount: The refund amount
    # - currency: The refund currency (e.g., USD)
    # - status: The refund status (e.g., pending, completed, failed)
    # - payment_id: The ID of the payment being refunded
    # - reason: The reason for the refund
    # - metadata: Additional metadata about the refund
    # - created_at: When the refund was created
    # - updated_at: When the refund was last updated
  end
end
