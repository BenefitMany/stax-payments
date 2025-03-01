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
  end
end
