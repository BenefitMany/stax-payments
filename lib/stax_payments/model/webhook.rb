# frozen_string_literal: true

module StaxPayments
  class Webhook < StaxModel
    # Common webhook attributes:
    # - id: The unique identifier for the webhook
    # - url: The URL to which webhook events will be sent
    # - events: The events that will trigger this webhook
    # - active: Whether the webhook is active
    # - description: A description of the webhook
    # - created_at: When the webhook was created
    # - updated_at: When the webhook was last updated
  end
end
