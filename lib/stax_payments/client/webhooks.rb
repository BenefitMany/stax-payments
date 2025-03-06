# frozen_string_literal: true

module StaxPayments
  class Client
    module Webhooks
      # List all webhooks
      # @param args [Hash] Optional parameters
      # @return [Array<StaxPayments::Webhook>] Array of webhook objects
      def webhooks(args = {})
        results = process_request(:get, '/webhooks', params: args)
        return results if results.is_a?(StaxError)

        results[:webhooks]&.map { |result| StaxPayments::Webhook.new(result) } || []
      end
      alias list_webhooks webhooks

      # Get a specific webhook
      # @param webhook_id [String] The ID of the webhook to retrieve
      # @return [StaxPayments::Webhook] The webhook object
      def webhook(webhook_id)
        result = process_request(:get, "/webhooks/#{webhook_id}")
        return result if result.is_a?(StaxError)

        StaxPayments::Webhook.new(result[:webhook])
      end
      alias get_webhook webhook

      # Create a new webhook
      # @param args [Hash] Webhook details (e.g., url, events)
      # @return [StaxPayments::Webhook] The created webhook object
      def create_webhook(args = {})
        result = process_request(:post, '/webhooks', body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Webhook.new(result[:webhook])
      end

      # Update a webhook
      # @param webhook_id [String] The ID of the webhook to update
      # @param args [Hash] Webhook details to update
      # @return [StaxPayments::Webhook] The updated webhook object
      def update_webhook(webhook_id, args = {})
        result = process_request(:put, "/webhooks/#{webhook_id}", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Webhook.new(result[:webhook])
      end

      # Delete a webhook
      # @param webhook_id [String] The ID of the webhook to delete
      # @return [Boolean] True if successful
      def delete_webhook(webhook_id)
        result = process_request(:delete, "/webhooks/#{webhook_id}")
        return result if result.is_a?(StaxError)

        result[:success] || false
      end
    end
  end
end
