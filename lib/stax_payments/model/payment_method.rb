# frozen_string_literal: true

module StaxPayments
  class PaymentMethod < StaxModel
    # Payment Method attributes based on Stax API documentation:
    # - id: The unique identifier for the payment method
    # - customer_id: The ID of the customer associated with this payment method
    # - merchant_id: The ID of the merchant that owns this payment method
    # - user_id: The ID of the user who created this payment method
    # - nickname: A friendly name for the payment method
    # - has_cvv: Whether the payment method has a CVV stored
    # - is_default: Whether this is the customer's default payment method
    # - method: The type of payment method (e.g., 'card', 'bank')
    # - meta: Additional metadata about the payment method (e.g., cardDisplay, routingDisplay, accountDisplay, etc.)
    # - bin_type: The type of card bin (e.g., 'DEBIT', 'CREDIT')
    # - person_name: The name of the person on the payment method
    # - card_type: For cards, the type of card (e.g., 'visa', 'mastercard')
    # - card_last_four: The last four digits of the card number
    # - card_exp: The expiration date of the card in MMYYYY format
    # - bank_name: For bank accounts, the name of the bank
    # - bank_type: For bank accounts, the type of account (e.g., 'checking', 'savings')
    # - bank_holder_type: For bank accounts, the type of account holder (e.g., 'personal', 'business')
    # - address_1: The first line of the billing address
    # - address_2: The second line of the billing address
    # - address_city: The city of the billing address
    # - address_state: The state of the billing address
    # - address_zip: The postal code of the billing address
    # - address_country: The country of the billing address
    # - purged_at: When the payment method was purged
    # - deleted_at: When the payment method was deleted
    # - created_at: When the payment method was created
    # - updated_at: When the payment method was last updated
    # - card_exp_datetime: The expiration date of the card as a datetime
    # - is_usable_in_vt: Whether the payment method can be used in the virtual terminal
    # - is_tokenized: Whether the payment method is tokenized
    # - au_last_event: The last account updater event (e.g., 'ReplacePaymentMethod', 'ContactCardHolder', 'ClosePaymentMethod')
    # - au_last_event_at: When the last account updater event occurred
    # - customer: The customer object associated with this payment method
    # - user: The user object associated with this payment method
    
    # Helper methods for payment method type
    def card?
      method == 'card'
    end
    
    def bank?
      method == 'bank'
    end
    
    # Helper method to check if payment method is default
    def default?
      is_default == 1 || is_default == true
    end
    
    # Helper method to check if payment method is deleted
    def deleted?
      !deleted_at.nil?
    end
    
    # Helper method to check if payment method is tokenized
    def tokenized?
      is_tokenized == true
    end
    
    # Helper method to check if payment method is usable in virtual terminal
    def usable_in_vt?
      is_usable_in_vt == true
    end
    
    # Helper method to check if payment method has CVV
    def has_cvv?
      has_cvv == 1 || has_cvv == true
    end
    
    # Helper method to get card expiration month
    def card_exp_month
      card_exp[0..1] if card_exp
    end
    
    # Helper method to get card expiration year
    def card_exp_year
      card_exp[2..5] if card_exp
    end
    
    # Helper method to format card expiration date
    def card_exp_formatted
      "#{card_exp_month}/#{card_exp_year}" if card_exp
    end
    
    # Helper method to check if card is expired
    def expired?
      return false unless card?
      return false unless card_exp_datetime
      
      Time.parse(card_exp_datetime) < Time.now
    end
    
    # Helper method to get card display number (masked)
    def card_display
      meta && meta[:card_display]
    end
    
    # Helper method to get routing display (masked)
    def routing_display
      meta && meta[:routing_display]
    end
    
    # Helper method to get account display (masked)
    def account_display
      meta && meta[:account_display]
    end
    
    # Helper method to check if card is eligible for card updater
    def eligible_for_card_updater?
      meta && meta[:eligible_for_card_updater]
    end
    
    # Helper method to get storage state
    def storage_state
      meta && meta[:storage_state]
    end
    
    # Helper method to get fingerprint
    def fingerprint
      meta && meta[:fingerprint]
    end
    
    # Helper method to check if card is a debit card
    def debit?
      bin_type == 'DEBIT'
    end
    
    # Helper method to check if card is a credit card
    def credit?
      bin_type == 'CREDIT'
    end
  end
end 