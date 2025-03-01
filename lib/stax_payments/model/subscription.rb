# frozen_string_literal: true

module StaxPayments
  class Subscription < StaxModel
    # Common subscription attributes:
    # - id: The unique identifier for the subscription
    # - customer_id: The ID of the customer associated with the subscription
    # - plan_id: The ID of the plan associated with the subscription
    # - status: The status of the subscription (e.g., active, canceled, past_due)
    # - current_period_start: The start date of the current billing period
    # - current_period_end: The end date of the current billing period
    # - cancel_at_period_end: Whether the subscription will be canceled at the end of the current period
    # - canceled_at: When the subscription was canceled
    # - ended_at: When the subscription ended
    # - trial_start: When the trial started
    # - trial_end: When the trial ends
    # - quantity: The quantity of the plan
    # - metadata: Additional metadata about the subscription
    # - created_at: When the subscription was created
    # - updated_at: When the subscription was last updated
  end
end
