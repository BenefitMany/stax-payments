#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry-byebug'
require 'dotenv/load'
require_relative '../lib/stax_payments'

Dotenv.load('../.env')

# Initialize the Stax Payments client
client = StaxPayments::Client.new(
  api_key: ENV['STAX_API_KEY'],
  environment: ENV['STAX_ENVIRONMENT'] || 'sandbox'
)

puts "=== Stax Payments Payment Methods Examples ==="
puts

# Example: List all payment methods
puts "Listing all payment methods..."
begin
  result = client.payment_methods(per_page: 10)

  if result.is_a?(StaxPayments::StaxError)
    puts "Error listing payment methods: #{result.message}"
    puts "Status code: #{result.status_code}"
    puts "Error details: #{result.error_details}"
  else
    payment_methods = result[:payment_methods]
    pagination = result[:pagination]

    puts "Found #{pagination[:total]} payment method(s) (showing page #{pagination[:current_page]} of #{pagination[:last_page]})"

    if payment_methods.empty?
      puts "No payment methods found."
    else
      payment_methods.each do |pm|
        puts "  - #{pm.nickname} (ID: #{pm.id})"
        puts "    Type: #{pm.method}"
        if pm.card?
          puts "    Card: #{pm.card_type} ending in #{pm.card_last_four}, expires #{pm.card_exp_formatted}"
        elsif pm.bank?
          puts "    Bank: #{pm.bank_name} (#{pm.bank_type})"
        end
        puts "    Default: #{pm.default? ? 'Yes' : 'No'}"
        puts "    Created: #{pm.created_at}"
        puts
      end
    end
  end
rescue => e
  puts "Error listing payment methods: #{e.message}"
end
puts

# Example: List payment methods with filtering
puts "Listing payment methods with filtering..."
begin
  # Filter by account updater event
  result = client.payment_methods(
    per_page: 10,
    au_last_event: 'ReplacePaymentMethod'
  )

  if result.is_a?(StaxPayments::StaxError)
    puts "Error listing payment methods: #{result.message}"
    puts "Status code: #{result.status_code}"
    puts "Error details: #{result.error_details}"
  else
    payment_methods = result[:payment_methods]
    pagination = result[:pagination]

    puts "Found #{pagination[:total]} payment method(s) with ReplacePaymentMethod event"

    if payment_methods.empty?
      puts "No payment methods found with the specified filter."
    else
      payment_methods.each do |pm|
        puts "  - #{pm.nickname} (ID: #{pm.id})"
        puts "    Type: #{pm.method}"
        puts "    Account Updater Event: #{pm.au_last_event}"
        puts "    Account Updater Event Date: #{pm.au_last_event_at}"
        puts
      end
    end
  end
rescue => e
  puts "Error listing payment methods: #{e.message}"
end
puts

# Example: Get a specific payment method
puts "Getting a specific payment method..."
begin
  # First, let's get a payment method ID from the list
  result = client.payment_methods(per_page: 1)

  if result.is_a?(StaxPayments::StaxError) || result[:payment_methods].empty?
    puts "No payment methods available to retrieve."
  else
    payment_method_id = result[:payment_methods].first.id
    puts "Using payment method ID: #{payment_method_id}"

    # Get the payment method details
    payment_method = client.payment_method(payment_method_id)

    if payment_method.is_a?(StaxPayments::StaxError)
      puts "Error retrieving payment method: #{payment_method.message}"
      puts "Status code: #{payment_method.status_code}"
      puts "Error details: #{payment_method.error_details}"
    else
      puts "Payment Method Details:"
      puts "  ID: #{payment_method.id}"
      puts "  Nickname: #{payment_method.nickname}"
      puts "  Type: #{payment_method.method}"
      puts "  Customer ID: #{payment_method.customer_id}"
      puts "  Person Name: #{payment_method.person_name}"

      if payment_method.card?
        puts "  Card Type: #{payment_method.card_type}"
        puts "  Last Four: #{payment_method.card_last_four}"
        puts "  Expiration: #{payment_method.card_exp_formatted}"
        puts "  Expired: #{payment_method.expired? ? 'Yes' : 'No'}"
        puts "  Bin Type: #{payment_method.bin_type}"
        puts "  Card Type: #{payment_method.debit? ? 'Debit' : (payment_method.credit? ? 'Credit' : 'Unknown')}"
        if payment_method.card_display
          puts "  Card Display: #{payment_method.card_display}"
        end
      elsif payment_method.bank?
        puts "  Bank Name: #{payment_method.bank_name}"
        puts "  Bank Type: #{payment_method.bank_type}"
        puts "  Bank Holder Type: #{payment_method.bank_holder_type}"
        puts "  Last Four: #{payment_method.card_last_four}"
        if payment_method.routing_display
          puts "  Routing Display: #{payment_method.routing_display}"
        end
        if payment_method.account_display
          puts "  Account Display: #{payment_method.account_display}"
        end
      end

      puts "  Default: #{payment_method.default? ? 'Yes' : 'No'}"
      puts "  Tokenized: #{payment_method.tokenized? ? 'Yes' : 'No'}"
      puts "  Usable in VT: #{payment_method.usable_in_vt? ? 'Yes' : 'No'}"

      if payment_method.storage_state
        puts "  Storage State: #{payment_method.storage_state}"
      end

      if payment_method.eligible_for_card_updater?
        puts "  Eligible for Card Updater: Yes"
      end

      puts "  Created: #{payment_method.created_at}"
      puts "  Updated: #{payment_method.updated_at}"
    end
  end
rescue => e
  puts "Error retrieving payment method: #{e.message}"
end
puts

# Example: List payment methods for a specific customer
puts "Listing payment methods for a specific customer..."
begin
  # First, let's get a customer
  customers_result = client.customers(limit: 1)
  customers = customers_result.is_a?(Hash) ? customers_result[:customers] : customers_result

  if customers.empty?
    puts "No customers found. Please create a customer first."
  else
    customer_id = customers.first.id
    puts "Using customer: #{customers.first.firstname} #{customers.first.lastname} (ID: #{customer_id})"

    # Get payment methods for the customer using the dedicated endpoint
    payment_methods = client.customer_payment_methods(customer_id)

    if payment_methods.is_a?(StaxPayments::StaxError)
      puts "Error listing customer payment methods: #{payment_methods.message}"
      puts "Status code: #{payment_methods.status_code}"
      puts "Error details: #{payment_methods.error_details}"
    elsif payment_methods.empty?
      puts "No payment methods found for this customer."
    else
      puts "Found #{payment_methods.size} payment method(s) for customer:"
      payment_methods.each do |pm|
        puts "  - #{pm.nickname} (ID: #{pm.id})"
        puts "    Type: #{pm.method}"
        if pm.card?
          puts "    Card: #{pm.card_type} ending in #{pm.card_last_four}, expires #{pm.card_exp_formatted}"
        elsif pm.bank?
          puts "    Bank: #{pm.bank_name} (#{pm.bank_type})"
        end
        puts "    Default: #{pm.default? ? 'Yes' : 'No'}"
        puts
      end
    end
  end
rescue => e
  puts "Error listing customer payment methods: #{e.message}"
end
puts

# Example: Delete a payment method
puts "Deleting a payment method..."
begin
  # This is commented out to prevent accidental deletion
  # Uncomment and modify to test deletion functionality

  # payment_method_id = 'PAYMENT_METHOD_ID_TO_DELETE'
  # puts "Deleting payment method ID: #{payment_method_id}"
  #
  # payment_method = client.delete_payment_method(payment_method_id)
  #
  # if payment_method.is_a?(StaxPayments::StaxError)
  #   puts "Error deleting payment method: #{payment_method.message}"
  #   puts "Status code: #{payment_method.status_code}"
  #   puts "Error details: #{payment_method.error_details}"
  # else
  #   puts "Payment method deleted successfully!"
  #   puts "ID: #{payment_method.id}"
  #   puts "Nickname: #{payment_method.nickname}"
  #   puts "Deleted at: #{payment_method.deleted_at}"
  # end

  puts "Deletion example is commented out to prevent accidental deletion."
  puts "Uncomment the code in the example file to test this functionality."
rescue => e
  puts "Error in deletion example: #{e.message}"
end
puts

# Example: Create a payment method
puts "Creating a payment method..."
begin
  # First, let's get a customer
  customers_result = client.customers(limit: 1)
  customers = customers_result.is_a?(Hash) ? customers_result[:customers] : customers_result

  if customers.empty?
    puts "No customers found. Please create a customer first."
  else
    customer_id = customers.first.id
    puts "Using customer: #{customers.first.firstname} #{customers.first.lastname} (ID: #{customer_id})"

    # This is commented out to prevent creating real payment methods
    # Uncomment and modify to test creation functionality

    # # Create a card payment method
    # card_params = {
    #   customer_id: customer_id,
    #   method: 'card',
    #   person_name: 'Steven Smith',
    #   card_number: '4111111111111111',
    #   card_cvv: '123',
    #   card_exp: '0427'
    # }
    #
    # puts "Creating card payment method for customer..."
    # payment_method = client.create_payment_method(card_params)
    #
    # if payment_method.is_a?(StaxPayments::StaxError)
    #   puts "Error creating payment method: #{payment_method.message}"
    #   puts "Status code: #{payment_method.status_code}"
    #   puts "Error details: #{payment_method.error_details}"
    # else
    #   puts "Payment method created successfully!"
    #   puts "ID: #{payment_method.id}"
    #   puts "Nickname: #{payment_method.nickname}"
    #   puts "Type: #{payment_method.method}"
    #   puts "Card Type: #{payment_method.card_type}"
    #   puts "Last Four: #{payment_method.card_last_four}"
    #   puts "Expiration: #{payment_method.card_exp_formatted}"
    # end
    #
    # # Create a bank account payment method
    # bank_params = {
    #   customer_id: customer_id,
    #   method: 'bank',
    #   person_name: 'Steven Smith',
    #   bank_account: '123456789',
    #   bank_routing: '123456789',
    #   bank_name: 'Test Bank',
    #   bank_type: 'checking',
    #   bank_holder_type: 'personal'
    # }
    #
    # puts "Creating bank payment method for customer..."
    # payment_method = client.create_payment_method(bank_params)
    #
    # if payment_method.is_a?(StaxPayments::StaxError)
    #   puts "Error creating payment method: #{payment_method.message}"
    #   puts "Status code: #{payment_method.status_code}"
    #   puts "Error details: #{payment_method.error_details}"
    # else
    #   puts "Payment method created successfully!"
    #   puts "ID: #{payment_method.id}"
    #   puts "Nickname: #{payment_method.nickname}"
    #   puts "Type: #{payment_method.method}"
    #   puts "Bank Name: #{payment_method.bank_name}"
    #   puts "Bank Type: #{payment_method.bank_type}"
    #   puts "Bank Holder Type: #{payment_method.bank_holder_type}"
    #   puts "Last Four: #{payment_method.card_last_four}"
    # end

    puts "Creation example is commented out to prevent creating real payment methods."
    puts "Uncomment the code in the example file to test this functionality."
  end
rescue => e
  puts "Error in creation example: #{e.message}"
end
puts

# Example: Update a payment method
puts "Updating a payment method..."
begin
  # First, let's get a payment method ID from the list
  result = client.payment_methods(per_page: 1)

  if result.is_a?(StaxPayments::StaxError) || result[:payment_methods].empty?
    puts "No payment methods available to update."
  else
    payment_method_id = result[:payment_methods].first.id
    puts "Using payment method ID: #{payment_method_id}"

    # This is commented out to prevent updating real payment methods
    # Uncomment and modify to test update functionality

    # # Update the payment method
    # update_params = {
    #   is_default: 1,
    #   person_name: 'Carl Junior Sr.',
    #   address_zip: '32944',
    #   address_country: 'USA'
    # }
    #
    # puts "Updating payment method..."
    # payment_method = client.update_payment_method(payment_method_id, update_params)
    #
    # if payment_method.is_a?(StaxPayments::StaxError)
    #   puts "Error updating payment method: #{payment_method.message}"
    #   puts "Status code: #{payment_method.status_code}"
    #   puts "Error details: #{payment_method.error_details}"
    # else
    #   puts "Payment method updated successfully!"
    #   puts "ID: #{payment_method.id}"
    #   puts "Nickname: #{payment_method.nickname}"
    #   puts "Person Name: #{payment_method.person_name}"
    #   puts "Default: #{payment_method.default? ? 'Yes' : 'No'}"
    #   puts "Address Zip: #{payment_method.address_zip}"
    #   puts "Address Country: #{payment_method.address_country}"
    # end

    puts "Update example is commented out to prevent updating real payment methods."
    puts "Uncomment the code in the example file to test this functionality."
  end
rescue => e
  puts "Error in update example: #{e.message}"
end
puts

# Example: Share a payment method with a third party
puts "Sharing a payment method with a third party..."
begin
  # First, let's get a payment method ID from the list
  result = client.payment_methods(per_page: 1)

  if result.is_a?(StaxPayments::StaxError) || result[:payment_methods].empty?
    puts "No payment methods available to share."
  else
    payment_method_id = result[:payment_methods].first.id
    puts "Using payment method ID: #{payment_method_id}"

    # This is commented out to prevent sharing real payment methods
    # Uncomment and modify to test sharing functionality

    # # Share the payment method with a third party
    # gateway_token = 'YOUR_GATEWAY_TOKEN' # This would be provided by your partner
    #
    # puts "Sharing payment method with third party..."
    # result = client.share_payment_method(payment_method_id, gateway_token)
    #
    # if result.is_a?(StaxPayments::StaxError)
    #   puts "Error sharing payment method: #{result.message}"
    #   puts "Status code: #{result.status_code}"
    #   puts "Error details: #{result.error_details}"
    # else
    #   puts "Payment method shared successfully!"
    #   puts "Transaction token: #{result['0']['transaction']['token']}"
    #   puts "Third party token: #{result['0']['transaction']['payment_method']['third_party_token']}"
    #   puts "Success message: #{result['success'].first}"
    # end

    puts "Sharing example is commented out to prevent sharing real payment methods."
    puts "Uncomment the code in the example file to test this functionality."
    puts "Note: You will need a valid gateway token from your partner to use this functionality."
  end
rescue => e
  puts "Error in sharing example: #{e.message}"
end
puts

# Example: Review surcharge information for a transaction
puts "Reviewing surcharge information for a transaction..."
begin
  # First, let's get a payment method ID from the list
  result = client.payment_methods(per_page: 1)

  if result.is_a?(StaxPayments::StaxError) || result[:payment_methods].empty?
    puts "No payment methods available to review surcharge."
  else
    payment_method_id = result[:payment_methods].first.id
    puts "Using payment method ID: #{payment_method_id}"

    # Review surcharge for a transaction
    total = 12.00
    puts "Reviewing surcharge for transaction total: $#{total}"

    surcharge_info = client.review_surcharge(payment_method_id, total)

    if surcharge_info.is_a?(StaxPayments::StaxError)
      puts "Error reviewing surcharge: #{surcharge_info.message}"
      puts "Status code: #{surcharge_info.status_code}"
      puts "Error details: #{surcharge_info.error_details}"
    else
      puts "Surcharge information:"
      puts "  Bin Type: #{surcharge_info[:bin_type]}"
      puts "  Surcharge Rate: #{surcharge_info[:surcharge_rate]}%"
      puts "  Surcharge Amount: $#{surcharge_info[:surcharge_amount]}"
      puts "  Total with Surcharge: $#{surcharge_info[:total_with_surcharge_amount]}"

      if surcharge_info[:bin_type] == 'DEBIT'
        puts "\nNote: Debit cards typically do not incur surcharges."
      end
    end
  end
rescue => e
  puts "Error in surcharge review example: #{e.message}"
end
puts

puts "=== Payment Methods Examples Completed ==="