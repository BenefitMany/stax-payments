# frozen_string_literal: true

module StaxPayments
  class Client
    module Cards
      # List all cards for a customer
      # @param customer_id [String] The ID of the customer
      # @param args [Hash] Optional parameters
      # @return [Array<StaxPayments::Card>] Array of card objects
      def customer_cards(customer_id, args = {})
        results = process_request(:get, "customers/#{customer_id}/cards", params: args)
        return results if results.is_a?(StaxError)

        results[:cards]&.map { |result| StaxPayments::Card.new(result) } || []
      end
      alias list_customer_cards customer_cards

      # Get a specific card
      # @param customer_id [String] The ID of the customer
      # @param card_id [String] The ID of the card to retrieve
      # @return [StaxPayments::Card] The card object
      def customer_card(customer_id, card_id)
        result = process_request(:get, "customers/#{customer_id}/cards/#{card_id}")
        return result if result.is_a?(StaxError)

        StaxPayments::Card.new(result[:card])
      end
      alias get_customer_card customer_card

      # Create a new card for a customer
      # @param customer_id [String] The ID of the customer
      # @param args [Hash] Card details
      # @return [StaxPayments::Card] The created card object
      def create_customer_card(customer_id, args = {})
        result = process_request(:post, "customers/#{customer_id}/cards", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Card.new(result[:card])
      end

      # Update a card
      # @param customer_id [String] The ID of the customer
      # @param card_id [String] The ID of the card to update
      # @param args [Hash] Card details to update
      # @return [StaxPayments::Card] The updated card object
      def update_customer_card(customer_id, card_id, args = {})
        result = process_request(:put, "customers/#{customer_id}/cards/#{card_id}", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Card.new(result[:card])
      end

      # Delete a card
      # @param customer_id [String] The ID of the customer
      # @param card_id [String] The ID of the card to delete
      # @return [Boolean] True if successful
      def delete_customer_card(customer_id, card_id)
        result = process_request(:delete, "customers/#{customer_id}/cards/#{card_id}")
        return result if result.is_a?(StaxError)

        result[:success] || false
      end
    end
  end
end
