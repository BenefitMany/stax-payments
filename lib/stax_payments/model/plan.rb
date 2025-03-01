# frozen_string_literal: true

module StaxPayments
  class Plan < StaxModel
    # Common plan attributes:
    # - id: The unique identifier for the plan
    # - name: The name of the plan
    # - amount: The amount to charge
    # - currency: The currency of the plan (e.g., USD)
    # - interval: The billing interval (e.g., month, year)
    # - interval_count: The number of intervals between billings
    # - trial_period_days: The number of days in the trial period
    # - metadata: Additional metadata about the plan
    # - created_at: When the plan was created
    # - updated_at: When the plan was last updated
  end
end
