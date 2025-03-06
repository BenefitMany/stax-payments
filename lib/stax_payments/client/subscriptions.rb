# frozen_string_literal: true

module StaxPayments
  class Client
    module Subscriptions
      # List all subscriptions
      # @param args [Hash] Optional parameters
      # @return [Array<StaxPayments::Subscription>] Array of subscription objects
      def subscriptions(args = {})
        results = process_request(:get, '/subscriptions', params: args)
        return results if results.is_a?(StaxError)

        results[:subscriptions]&.map { |result| StaxPayments::Subscription.new(result) } || []
      end
      alias list_subscriptions subscriptions

      # Get a specific subscription
      # @param subscription_id [String] The ID of the subscription to retrieve
      # @return [StaxPayments::Subscription] The subscription object
      def subscription(subscription_id)
        result = process_request(:get, "/subscriptions/#{subscription_id}")
        return result if result.is_a?(StaxError)

        StaxPayments::Subscription.new(result[:subscription])
      end
      alias get_subscription subscription

      # Create a new subscription
      # @param args [Hash] Subscription details
      # @return [StaxPayments::Subscription] The created subscription object
      def create_subscription(args = {})
        result = process_request(:post, '/subscriptions', body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Subscription.new(result[:subscription])
      end

      # Update a subscription
      # @param subscription_id [String] The ID of the subscription to update
      # @param args [Hash] Subscription details to update
      # @return [StaxPayments::Subscription] The updated subscription object
      def update_subscription(subscription_id, args = {})
        result = process_request(:put, "/subscriptions/#{subscription_id}", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Subscription.new(result[:subscription])
      end

      # Cancel a subscription
      # @param subscription_id [String] The ID of the subscription to cancel
      # @param args [Hash] Optional parameters (e.g., cancel_at_period_end)
      # @return [StaxPayments::Subscription] The canceled subscription object
      def cancel_subscription(subscription_id, args = {})
        result = process_request(:post, "/subscriptions/#{subscription_id}/cancel", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Subscription.new(result[:subscription])
      end
    end
  end
end
