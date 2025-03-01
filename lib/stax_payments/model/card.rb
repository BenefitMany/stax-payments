# frozen_string_literal: true

module StaxPayments
  class Card < StaxModel
    # Common card attributes:
    # - id: The unique identifier for the card
    # - customer_id: The ID of the customer associated with the card
    # - card_type: The type of card (e.g., visa, mastercard)
    # - last4: The last 4 digits of the card number
    # - expiration_month: The expiration month of the card
    # - expiration_year: The expiration year of the card
    # - cardholder_name: The name of the cardholder
    # - billing_address: The billing address associated with the card
    # - is_default: Whether this is the default card for the customer
    # - created_at: When the card was created
    # - updated_at: When the card was last updated
  end
end
