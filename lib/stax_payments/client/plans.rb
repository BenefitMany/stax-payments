# frozen_string_literal: true

module StaxPayments
  class Client
    module Plans
      # List all plans
      # @param args [Hash] Optional parameters
      # @return [Array<StaxPayments::Plan>] Array of plan objects
      def plans(args = {})
        results = process_request(:get, 'plans', params: args)
        return results if results.is_a?(StaxError)

        results[:plans]&.map { |result| StaxPayments::Plan.new(result) } || []
      end
      alias list_plans plans

      # Get a specific plan
      # @param plan_id [String] The ID of the plan to retrieve
      # @return [StaxPayments::Plan] The plan object
      def plan(plan_id)
        result = process_request(:get, "plans/#{plan_id}")
        return result if result.is_a?(StaxError)

        StaxPayments::Plan.new(result[:plan])
      end
      alias get_plan plan

      # Create a new plan
      # @param args [Hash] Plan details
      # @return [StaxPayments::Plan] The created plan object
      def create_plan(args = {})
        result = process_request(:post, 'plans', body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Plan.new(result[:plan])
      end

      # Update a plan
      # @param plan_id [String] The ID of the plan to update
      # @param args [Hash] Plan details to update
      # @return [StaxPayments::Plan] The updated plan object
      def update_plan(plan_id, args = {})
        result = process_request(:put, "plans/#{plan_id}", body: args)
        return result if result.is_a?(StaxError)

        StaxPayments::Plan.new(result[:plan])
      end

      # Delete a plan
      # @param plan_id [String] The ID of the plan to delete
      # @return [Boolean] True if successful
      def delete_plan(plan_id)
        result = process_request(:delete, "plans/#{plan_id}")
        return result if result.is_a?(StaxError)

        result[:success] || false
      end
    end
  end
end
