# frozen_string_literal: true

module StaxPayments
  class Invoice < StaxModel
    # Invoice attributes based on Stax API documentation:
    # - id: The unique identifier for the invoice
    # - merchant_id: The ID of the merchant associated with the invoice
    # - user_id: The ID of the user who created the invoice
    # - customer_id: The ID of the customer associated with the invoice
    # - total: The total amount of the invoice
    # - meta: Additional metadata about the invoice (JSON object)
    #   - tax: The tax amount
    #   - subtotal: The subtotal amount
    #   - lineItems: Array of line items (item, details, quantity, price)
    #   - memo: Customer facing memo
    #   - internalMemo: Internal memo for the merchant
    #   - isCCPaymentEnabled: Whether credit card payments are enabled
    #   - isACHPaymentEnabled: Whether ACH payments are enabled
    #   - isTipEnabled: Whether tips are enabled
    # - status: The status of the invoice (DRAFT, SENT, PAID, etc.)
    # - sent_at: When the invoice was sent
    # - viewed_at: When the invoice was viewed
    # - paid_at: When the invoice was paid
    # - schedule_id: The ID of the schedule associated with the invoice
    # - reminder_id: The ID of the reminder associated with the invoice
    # - payment_method_id: The ID of the payment method used to pay the invoice
    # - url: The URL for the invoice payment page
    # - is_webpayment: Whether the invoice is a web payment
    # - is_partial_payment_enabled: Whether partial payments are enabled
    # - deleted_at: When the invoice was deleted (if applicable)
    # - created_at: When the invoice was created
    # - updated_at: When the invoice was last updated
    # - payment_attempt_failed: Whether a payment attempt failed
    # - payment_attempt_message: Message about a failed payment attempt
    # - balance_due: The remaining balance due on the invoice
    # - total_paid: The total amount paid on the invoice
    # - payment_meta: Metadata about payments made on the invoice
    # - customer: The customer object associated with the invoice
    # - user: The user object associated with the invoice
    # - files: Array of files attached to the invoice
    # - child_transactions: Array of transactions associated with the invoice
    # - reminder: The reminder object associated with the invoice
    
    # Helper method to check if the invoice is a draft
    def draft?
      status == 'DRAFT'
    end
    
    # Helper method to check if the invoice has been sent
    def sent?
      status == 'SENT'
    end
    
    # Helper method to check if the invoice has been paid
    def paid?
      status == 'PAID'
    end
    
    # Helper method to check if the invoice has been voided
    def voided?
      status == 'VOID'
    end
    
    # Helper method to check if the invoice has been deleted
    def deleted?
      !deleted_at.nil?
    end
    
    # Helper method to check if the invoice has been viewed
    def viewed?
      !viewed_at.nil?
    end
    
    # Helper method to check if the invoice has a balance due
    def has_balance_due?
      balance_due.to_f > 0
    end
    
    # Helper method to check if the invoice has been partially paid
    def partially_paid?
      total_paid.to_f > 0 && has_balance_due?
    end
    
    # Helper method to get the total amount in dollars
    def total_in_dollars
      total.to_f
    end
    
    # Helper method to get the balance due in dollars
    def balance_due_in_dollars
      balance_due.to_f
    end
    
    # Helper method to get the total paid in dollars
    def total_paid_in_dollars
      total_paid.to_f
    end
    
    # Helper method to get the line items from the meta
    def line_items
      meta && meta[:line_items] || []
    end
    
    # Helper method to get the tax amount from the meta
    def tax
      meta && meta[:tax] || 0
    end
    
    # Helper method to get the subtotal from the meta
    def subtotal
      meta && meta[:subtotal] || 0
    end
    
    # Helper method to get the customer facing memo from the meta
    def memo
      meta && meta[:memo]
    end
    
    # Helper method to get the internal memo from the meta
    def internal_memo
      meta && meta[:internal_memo]
    end
    
    # Helper method to check if credit card payments are enabled
    def cc_payment_enabled?
      meta && meta[:is_cc_payment_enabled] == true
    end
    
    # Helper method to check if ACH payments are enabled
    def ach_payment_enabled?
      meta && meta[:is_ach_payment_enabled] == true
    end
    
    # Helper method to check if tips are enabled
    def tip_enabled?
      meta && meta[:is_tip_enabled] == true
    end
    
    # Helper method to get the customer name
    def customer_name
      return nil unless customer
      
      if customer[:firstname] || customer[:lastname]
        [customer[:firstname], customer[:lastname]].compact.join(' ')
      else
        customer[:company]
      end
    end
    
    # Helper method to get the customer email
    def customer_email
      customer && customer[:email]
    end
  end
end
