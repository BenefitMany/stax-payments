# frozen_string_literal: true

module StaxPayments
  class Invoice < StaxModel
    # Common invoice attributes:
    # - id: The unique identifier for the invoice
    # - customer_id: The ID of the customer associated with the invoice
    # - amount: The total amount of the invoice
    # - currency: The currency of the invoice (e.g., USD)
    # - status: The status of the invoice (e.g., draft, sent, paid, void)
    # - due_date: The due date of the invoice
    # - items: The line items on the invoice
    # - subtotal: The subtotal amount of the invoice
    # - tax: The tax amount of the invoice
    # - discount: The discount amount of the invoice
    # - notes: Notes on the invoice
    # - metadata: Additional metadata about the invoice
    # - created_at: When the invoice was created
    # - updated_at: When the invoice was last updated
  end
end
