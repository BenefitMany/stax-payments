# frozen_string_literal: true

module StaxPayments
  class Transaction < StaxModel
    # Transaction attributes based on Stax API documentation:
    # - id: The unique identifier for the transaction
    # - amount: The transaction amount in cents (e.g., 1000 for $10.00)
    # - currency: The transaction currency (e.g., USD)
    # - status: The transaction status (e.g., pending, completed, failed)
    # - type: The transaction type (e.g., charge, refund, authorization)
    # - customer_id: The ID of the customer associated with the transaction
    # - payment_method_id: The ID of the payment method used
    # - payment_method_type: The type of payment method (e.g., card, bank_account)
    # - description: A description of the transaction
    # - reference_id: A merchant-defined reference ID for the transaction
    # - order_id: A merchant-defined order ID for the transaction
    # - invoice_id: The ID of the invoice associated with the transaction
    # - billing_address: The billing address associated with the transaction
    # - shipping_address: The shipping address associated with the transaction
    # - tax_amount: The tax amount for the transaction in cents
    # - tax_exempt: Whether the transaction is tax exempt
    # - tax_exempt_id: The tax exempt ID for the transaction
    # - avs_result: The Address Verification System result
    # - cvv_result: The Card Verification Value result
    # - processor_id: The ID of the processor used for the transaction
    # - processor_type: The type of processor used for the transaction
    # - processor_response: The response from the processor
    # - processor_response_code: The response code from the processor
    # - processor_response_text: The response text from the processor
    # - processor_authorization_code: The authorization code from the processor
    # - processor_transaction_id: The transaction ID from the processor
    # - metadata: Additional metadata about the transaction
    # - created_at: When the transaction was created
    # - updated_at: When the transaction was last updated
    # - settled_at: When the transaction was settled
    # - is_refundable: Whether the transaction can be refunded
    # - is_cnp_refundable: Whether the transaction can be refunded without the card present
    # - success: Success flag (1 for success, 0 for failure)
    # - message: Message from the processor or error message
    # - child_transactions: Array of child transactions (refunds, voids)
    # - source: Source of the transaction (e.g., 'api', 'terminalservice.dejavoo')
    # - pre_auth: Whether the transaction is a pre-authorization
    
    # Helper methods for transaction status
    def pending?
      status == 'pending'
    end
    
    def completed?
      status == 'completed'
    end
    
    def failed?
      status == 'failed'
    end
    
    def voided?
      status == 'voided'
    end
    
    def refunded?
      status == 'refunded'
    end
    
    # Helper methods for transaction type
    def charge?
      type == 'charge'
    end
    
    def refund?
      type == 'refund'
    end
    
    def authorization?
      type == 'authorization'
    end
    
    def capture?
      type == 'capture'
    end
    
    def void?
      type == 'void'
    end
    
    # Helper method to get the amount in dollars
    def amount_in_dollars
      amount.to_f / 100 if amount
    end

    # Helper method to check if transaction is a pre-authorization
    def pre_auth?
      pre_auth == true
    end

    # Helper method to check if transaction is successful
    def successful?
      success == 1
    end

    # Helper method to check if transaction has settled
    def settled?
      !settled_at.nil?
    end

    # Helper method to check if transaction has child transactions
    def has_child_transactions?
      child_transactions && !child_transactions.empty?
    end

    # Helper method to get total refunded amount
    def total_refunded
      return 0 unless has_child_transactions?

      child_transactions
        .select { |t| t[:type] == 'refund' && t[:success] == 1 }
        .sum { |t| t[:amount].to_i }
    end

    # Helper method to get total refunded amount in dollars
    def total_refunded_in_dollars
      total_refunded.to_f / 100
    end

    # Helper method to check if transaction is fully refunded
    def fully_refunded?
      return false unless has_child_transactions?
      
      total_refunded >= amount.to_i
    end

    # Helper method to get remaining refundable amount
    def remaining_refundable_amount
      return 0 unless is_refundable
      
      [amount.to_i - total_refunded, 0].max
    end

    # Helper method to get remaining refundable amount in dollars
    def remaining_refundable_amount_in_dollars
      remaining_refundable_amount.to_f / 100
    end
  end
end
