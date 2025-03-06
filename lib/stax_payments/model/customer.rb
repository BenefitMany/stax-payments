# frozen_string_literal: true

module StaxPayments
  class Customer < StaxModel
    # Customer attributes based on Stax API documentation:
    # - id: The unique identifier for the customer
    # - firstname: The customer's first name (required if no lastname, email, company supplied)
    # - lastname: The customer's last name (required if no firstname, email, company supplied)
    # - email: The customer's email address (required if no firstname, lastname, company supplied)
    # - company: The customer's company name (required if no firstname, lastname, email supplied)
    # - phone: The customer's phone number (matching regex: /[0-9]{10,15}/)
    # - address_1: The customer's address line 1
    # - address_2: The customer's address line 2
    # - address_city: The customer's city
    # - address_state: The customer's state (2 characters)
    # - address_zip: The customer's postal code (up to 16 characters)
    # - address_country: The customer's country (3 characters)
    # - notes: Additional notes about the customer (not visible to customer)
    # - reference: A merchant-defined reference string
    # - cc_emails: Array of email addresses to CC on communications
    # - cc_sms: Array of phone numbers to CC on SMS communications
    # - allow_invoice_credit_card_payments: Whether to allow credit card payments for invoices
    # - options: Additional options for the customer
    # - created_at: When the customer was created
    # - updated_at: When the customer was last updated
    # - deleted_at: When the customer was deleted (if applicable)
    # - gravatar: The customer's Gravatar URL
    # - has_address: Whether the customer has a complete address
    # - missing_address_components: Array of missing address components
    
    # Helper method to get the full name
    def full_name
      [firstname, lastname].compact.join(' ')
    end
    
    # Helper method to check if the customer has a complete address
    def has_complete_address?
      has_address == true
    end
    
    # Helper method to check if the customer has been deleted
    def deleted?
      !deleted_at.nil?
    end
    
    # Helper method to get the formatted address
    def formatted_address
      parts = []
      parts << address_1 if address_1
      parts << address_2 if address_2
      city_state_zip = []
      city_state_zip << address_city if address_city
      city_state_zip << address_state if address_state
      city_state_zip << address_zip if address_zip
      parts << city_state_zip.join(', ') unless city_state_zip.empty?
      parts << address_country if address_country
      
      parts.join("\n")
    end
  end
end
