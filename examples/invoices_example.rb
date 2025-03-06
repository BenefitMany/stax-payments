#!/usr/bin/env ruby
# frozen_string_literal: true

require 'dotenv/load'
require 'stax_payments'

# Initialize the Stax Payments client
client = StaxPayments::Client.new(
  api_key: ENV['STAX_API_KEY'],
  api_secret: ENV['STAX_API_SECRET'],
  environment: ENV['STAX_ENVIRONMENT'] || 'sandbox'
)

puts "=== Stax Payments Invoice Examples ==="
puts

# Example: Create an invoice
puts "Creating a new invoice..."
begin
  # First, let's get a customer to associate with the invoice
  customers_result = client.customers(limit: 1)
  customers = customers_result.is_a?(Hash) ? customers_result[:customers] : customers_result
  
  if customers.empty?
    puts "No customers found. Creating a customer first..."
    customer = client.create_customer(
      firstname: 'John',
      lastname: 'Doe',
      email: 'john.doe@example.com',
      company: 'Example Corp',
      phone: '555-123-4567'
    )
    customer_id = customer.id
    puts "Created customer: #{customer.firstname} #{customer.lastname} (ID: #{customer.id})"
  else
    customer_id = customers.first.id
    puts "Using existing customer: #{customers.first.firstname} #{customers.first.lastname} (ID: #{customer_id})"
  end
  
  # Create the invoice
  invoice = client.create_invoice(
    customer_id: customer_id,
    meta: {
      tax: 2.00,
      subtotal: 10.00,
      lineItems: [
        {
          item: 'Premium Service',
          details: 'Monthly subscription to premium services',
          quantity: 1,
          price: 10.00
        }
      ],
      isCCPaymentEnabled: true,
      isACHPaymentEnabled: true,
      isTipEnabled: false,
      memo: 'Thank you for your business!',
      reference: 'INV-2023-001'
    },
    total: '12.00',
    url: 'https://app.staxpayments.com/#/bill/',
    is_partial_payment_enabled: false
  )
  
  puts "Invoice created successfully!"
  puts "Invoice ID: #{invoice.id}"
  puts "Total: $#{invoice.total_in_dollars}"
  puts "Status: #{invoice.status}"
  puts "Created at: #{invoice.created_at}"
  puts
rescue => e
  puts "Error creating invoice: #{e.message}"
  puts
end

# Example: Get a specific invoice
puts "Retrieving an invoice..."
begin
  # Get the most recent invoice
  invoices_result = client.invoices(limit: 1)
  invoices = invoices_result[:invoices]
  
  if invoices.empty?
    puts "No invoices found."
  else
    invoice_id = invoices.first.id
    invoice = client.invoice(invoice_id)
    
    puts "Invoice details:"
    puts "ID: #{invoice.id}"
    puts "Customer: #{invoice.customer_name}" if invoice.customer_name
    puts "Total: $#{invoice.total_in_dollars}"
    puts "Balance Due: $#{invoice.balance_due_in_dollars}"
    puts "Status: #{invoice.status}"
    puts "Created at: #{invoice.created_at}"
    
    # Display line items if available
    if invoice.line_items && !invoice.line_items.empty?
      puts "\nLine Items:"
      invoice.line_items.each do |item|
        puts "- #{item['item']}: #{item['quantity']} x $#{item['price']} = $#{item['quantity'].to_f * item['price'].to_f}"
      end
    end
    
    puts "\nMemo: #{invoice.memo}" if invoice.memo
    puts
  end
rescue => e
  puts "Error retrieving invoice: #{e.message}"
  puts
end

# Example: Get an invoice with search keywords
puts "Retrieving an invoice with search keywords..."
begin
  # Get the most recent invoice
  invoices_result = client.invoices(limit: 1)
  invoices = invoices_result[:invoices]
  
  if invoices.empty?
    puts "No invoices found."
  else
    invoice_id = invoices.first.id
    
    # Retrieve the invoice with search keywords
    keywords = ['Premium', 'Service']
    invoice = client.invoice(invoice_id, keywords: keywords)
    
    puts "Invoice details (searched with keywords: #{keywords.join(', ')}):"
    puts "ID: #{invoice.id}"
    puts "Customer: #{invoice.customer_name}" if invoice.customer_name
    puts "Total: $#{invoice.total_in_dollars}"
    puts "Status: #{invoice.status}"
    
    # Display payment method if available
    if invoice.payment_method
      puts "\nPayment Method:"
      puts "Type: #{invoice.payment_method['method']}"
      puts "Card Type: #{invoice.payment_method['card_type']}" if invoice.payment_method['card_type']
      puts "Last Four: #{invoice.payment_method['card_last_four']}" if invoice.payment_method['card_last_four']
      puts "Bank Name: #{invoice.payment_method['bank_name']}" if invoice.payment_method['bank_name']
    end
    
    # Display customer details if available
    if invoice.customer
      puts "\nCustomer Details:"
      puts "Name: #{invoice.customer['firstname']} #{invoice.customer['lastname']}"
      puts "Email: #{invoice.customer['email']}"
      puts "Phone: #{invoice.customer['phone']}"
      puts "Address: #{invoice.customer['address_1']}, #{invoice.customer['address_city']}, #{invoice.customer['address_state']} #{invoice.customer['address_zip']}"
    end
    
    puts
  end
rescue => e
  puts "Error retrieving invoice with keywords: #{e.message}"
  puts
end

# Example: List invoices with basic pagination
puts "Listing invoices with pagination..."
begin
  # List invoices with pagination
  page = 1
  limit = 5
  
  result = client.invoices(page: page, limit: limit)
  invoices = result[:invoices]
  pagination = result[:pagination]
  
  if invoices.empty?
    puts "No invoices found."
  else
    puts "Found #{pagination[:total]} total invoices (showing page #{pagination[:current_page]} of #{pagination[:last_page]}, #{pagination[:per_page]} per page)"
    
    invoices.each do |invoice|
      puts "- ID: #{invoice.id}, Customer: #{invoice.customer_id}, Total: $#{invoice.total_in_dollars}, Status: #{invoice.status}"
    end
    
    puts "\nPagination info:"
    puts "Current page: #{pagination[:current_page]}"
    puts "Total pages: #{pagination[:last_page]}"
    puts "Results per page: #{pagination[:per_page]}"
    puts "Total results: #{pagination[:total]}"
    puts "Results range: #{pagination[:from]} to #{pagination[:to]}"
  end
  puts
rescue => e
  puts "Error listing invoices: #{e.message}"
  puts
end

# Example: Search invoices by keywords
puts "Searching invoices by keywords..."
begin
  # Search for invoices with specific keywords
  keywords = ['Premium', 'Service']
  
  result = client.invoices(keywords: keywords, limit: 10)
  invoices = result[:invoices]
  pagination = result[:pagination]
  
  if invoices.empty?
    puts "No invoices found matching keywords: #{keywords.join(', ')}"
  else
    puts "Found #{pagination[:total]} invoices matching keywords: #{keywords.join(', ')}"
    
    invoices.each do |invoice|
      puts "- ID: #{invoice.id}, Total: $#{invoice.total_in_dollars}, Status: #{invoice.status}"
    end
  end
  puts
rescue => e
  puts "Error searching invoices: #{e.message}"
  puts
end

# Example: Filter invoices by payment method
puts "Filtering invoices by payment method..."
begin
  # Filter invoices by payment method (card)
  result = client.invoices(payment_method: 'card', limit: 10)
  invoices = result[:invoices]
  pagination = result[:pagination]
  
  if invoices.empty?
    puts "No invoices found with payment method: card"
  else
    puts "Found #{pagination[:total]} invoices with payment method: card"
    
    invoices.each do |invoice|
      puts "- ID: #{invoice.id}, Total: $#{invoice.total_in_dollars}, Status: #{invoice.status}"
    end
  end
  puts
rescue => e
  puts "Error filtering invoices: #{e.message}"
  puts
end

# Example: Filter invoices by status
puts "Filtering invoices by status..."
begin
  # Filter invoices by status (DRAFT)
  result = client.invoices(status: 'DRAFT', limit: 10)
  invoices = result[:invoices]
  pagination = result[:pagination]
  
  if invoices.empty?
    puts "No invoices found with status: DRAFT"
  else
    puts "Found #{pagination[:total]} invoices with status: DRAFT"
    
    invoices.each do |invoice|
      puts "- ID: #{invoice.id}, Total: $#{invoice.total_in_dollars}, Created at: #{invoice.created_at}"
    end
  end
  puts
rescue => e
  puts "Error filtering invoices by status: #{e.message}"
  puts
end

# Example: Update an invoice
puts "Updating an invoice..."
begin
  # Get the most recent invoice
  result = client.invoices(limit: 1)
  invoices = result[:invoices]
  
  if invoices.empty?
    puts "No invoices found to update."
  else
    invoice_id = invoices.first.id
    
    # Only update if the invoice is in draft status
    if invoices.first.draft?
      updated_invoice = client.update_invoice(invoice_id, {
        meta: {
          tax: 3.00,
          subtotal: 10.00,
          lineItems: [
            {
              item: 'Premium Service',
              details: 'Monthly subscription to premium services',
              quantity: 1,
              price: 10.00
            }
          ],
          memo: 'Thank you for your business! Updated memo.',
          reference: 'INV-2023-001-UPDATED'
        },
        total: '13.00'
      })
      
      puts "Invoice updated successfully!"
      puts "Invoice ID: #{updated_invoice.id}"
      puts "New Total: $#{updated_invoice.total_in_dollars}"
      puts "Updated memo: #{updated_invoice.memo}"
      puts
    else
      puts "Cannot update invoice with ID #{invoice_id} because it's not in draft status."
      puts
    end
  end
rescue => e
  puts "Error updating invoice: #{e.message}"
  puts
end

# Example: Update an invoice with invoice_date_at
puts "Updating an invoice with invoice_date_at..."
begin
  # Get the most recent invoice
  result = client.invoices(limit: 1)
  invoices = result[:invoices]
  
  if invoices.empty?
    puts "No invoices found to update."
  else
    invoice_id = invoices.first.id
    
    # Only update if the invoice is in draft status
    if invoices.first.draft?
      # Set the invoice date to a specific date (e.g., yesterday)
      invoice_date = (Time.now - 86400).strftime('%Y-%m-%d %H:%M:%S')
      
      updated_invoice = client.update_invoice(invoice_id, {
        meta: {
          tax: 5.00,
          subtotal: 20.00,
          lineItems: [
            {
              item: 'Premium Service - Updated',
              details: 'Monthly subscription to premium services - Updated',
              quantity: 2,
              price: 10.00
            }
          ],
          memo: 'Thank you for your business! With custom invoice date.'
        },
        total: '25.00',
        invoice_date_at: invoice_date
      })
      
      puts "Invoice updated with custom date successfully!"
      puts "Invoice ID: #{updated_invoice.id}"
      puts "New Total: $#{updated_invoice.total_in_dollars}"
      puts "Invoice Date: #{invoice_date}"
      puts "Updated memo: #{updated_invoice.memo}"
      puts
    else
      puts "Cannot update invoice with ID #{invoice_id} because it's not in draft status."
      puts
    end
  end
rescue => e
  puts "Error updating invoice with custom date: #{e.message}"
  puts
end

# Example: Update an invoice with payment method
puts "Updating an invoice with payment method..."
begin
  # Get the most recent invoice
  result = client.invoices(limit: 1)
  invoices = result[:invoices]
  
  if invoices.empty?
    puts "No invoices found to update."
  else
    invoice_id = invoices.first.id
    
    # Only update if the invoice is in draft status
    if invoices.first.draft?
      # Get a payment method for the customer
      customer_id = invoices.first.customer_id
      
      if customer_id
        # Get payment methods for the customer
        payment_methods = client.customer_payment_methods(customer_id) rescue []
        
        if payment_methods.empty?
          puts "No payment methods found for customer. Cannot update invoice with payment method."
        else
          payment_method_id = payment_methods.first.id
          
          updated_invoice = client.update_invoice(invoice_id, {
            payment_method_id: payment_method_id,
            meta: {
              tax: 4.00,
              subtotal: 20.00,
              lineItems: [
                {
                  item: 'Premium Service with Payment Method',
                  details: 'Monthly subscription with pre-selected payment method',
                  quantity: 2,
                  price: 10.00
                }
              ]
            },
            total: '24.00'
          })
          
          puts "Invoice updated with payment method successfully!"
          puts "Invoice ID: #{updated_invoice.id}"
          puts "New Total: $#{updated_invoice.total_in_dollars}"
          puts "Payment Method ID: #{updated_invoice.payment_method_id}"
          
          # Display payment method details if available
          if updated_invoice.payment_method
            puts "\nPayment Method Details:"
            puts "Type: #{updated_invoice.payment_method['method']}"
            puts "Card Type: #{updated_invoice.payment_method['card_type']}" if updated_invoice.payment_method['card_type']
            puts "Last Four: #{updated_invoice.payment_method['card_last_four']}" if updated_invoice.payment_method['card_last_four']
          end
          puts
        end
      else
        puts "Invoice has no associated customer. Cannot update with payment method."
        puts
      end
    else
      puts "Cannot update invoice with ID #{invoice_id} because it's not in draft status."
      puts
    end
  end
rescue => e
  puts "Error updating invoice with payment method: #{e.message}"
  puts
end

# Example: Send an invoice
puts "Sending an invoice..."
begin
  # Get the most recent invoice
  result = client.invoices(limit: 1)
  invoices = result[:invoices]
  
  if invoices.empty?
    puts "No invoices found to send."
  else
    invoice_id = invoices.first.id
    
    # Only send if the invoice is in draft status
    if invoices.first.draft?
      sent_invoice = client.send_invoice(invoice_id)
      
      puts "Invoice sent successfully!"
      puts "Invoice ID: #{sent_invoice.id}"
      puts "Status: #{sent_invoice.status}"
      puts "Sent at: #{sent_invoice.sent_at}"
      puts
    else
      puts "Cannot send invoice with ID #{invoice_id} because it's not in draft status."
      puts
    end
  end
rescue => e
  puts "Error sending invoice: #{e.message}"
  puts
end

# Example: Send an invoice via email with CC recipients
puts "Sending an invoice via email with CC recipients..."
begin
  # Get the most recent invoice
  result = client.invoices(limit: 1)
  invoices = result[:invoices]
  
  if invoices.empty?
    puts "No invoices found to send via email."
  else
    invoice_id = invoices.first.id
    
    # Only send if the invoice is in draft status or already sent
    if invoices.first.draft? || invoices.first.sent?
      # Define CC email addresses
      cc_emails = ['cc_recipient1@example.com', 'cc_recipient2@example.com']
      
      # Send the invoice via email
      sent_invoice = client.send_invoice_email(invoice_id, {
        cc_emails: cc_emails
      })
      
      puts "Invoice sent via email successfully!"
      puts "Invoice ID: #{sent_invoice.id}"
      puts "Status: #{sent_invoice.status}"
      puts "Sent at: #{sent_invoice.sent_at}"
      puts "CC Recipients: #{cc_emails.join(', ')}"
      puts
    else
      puts "Cannot send invoice with ID #{invoice_id} via email because it's not in draft or sent status."
      puts
    end
  end
rescue StaxPayments::StaxError => e
  puts "Error sending invoice via email: #{e.message}"
  puts "Status code: #{e.status_code}"
  puts "Error details: #{e.error_details}"
  puts
end

# Example: Send an invoice via SMS
puts "Sending an invoice via SMS..."
begin
  # Get the most recent invoice
  result = client.invoices(limit: 1)
  invoices = result[:invoices]
  
  if invoices.empty?
    puts "No invoices found to send via SMS."
  else
    invoice_id = invoices.first.id
    
    # Only send if the invoice is in draft status or already sent
    if invoices.first.draft? || invoices.first.sent?
      # Get the customer's phone number or use a default one
      customer_phone = invoices.first.customer && invoices.first.customer[:phone] || '5555555555'
      
      # Clean the phone number (remove non-digits)
      phone = customer_phone.gsub(/\D/, '')
      
      # Send the invoice via SMS with a custom message
      sent_invoice = client.send_invoice_sms(invoice_id, {
        phone: phone,
        message: 'Your invoice is ready for payment. Thank you for your business!'
      })
      
      puts "Invoice sent via SMS successfully!"
      puts "Invoice ID: #{sent_invoice.id}"
      puts "Status: #{sent_invoice.status}"
      puts "Sent at: #{sent_invoice.sent_at}"
      puts "Phone: #{phone}"
      puts
    else
      puts "Cannot send invoice with ID #{invoice_id} via SMS because it's not in draft or sent status."
      puts
    end
  end
rescue StaxPayments::StaxError => e
  puts "Error sending invoice via SMS: #{e.message}"
  puts "Status code: #{e.status_code}"
  puts "Error details: #{e.error_details}"
  puts
end

# Example: Pay an invoice
puts "Paying an invoice..."
begin
  # Get the most recent invoice that's in SENT status
  result = client.invoices(status: 'SENT', limit: 5)
  sent_invoices = result[:invoices]
  
  if sent_invoices.empty?
    puts "No sent invoices found to pay."
  else
    invoice_id = sent_invoices.first.id
    
    # First, let's get a payment method for the customer
    customer_id = sent_invoices.first.customer_id
    
    if customer_id
      # Get payment methods for the customer
      payment_methods = client.customer_payment_methods(customer_id) rescue []
      
      if payment_methods.empty?
        puts "No payment methods found for customer. Cannot pay invoice."
      else
        payment_method_id = payment_methods.first.id
        
        # Pay the invoice
        paid_invoice = client.pay_invoice(invoice_id, {
          payment_method_id: payment_method_id,
          email_receipt: true,
          apply_balance: sent_invoices.first.total_in_dollars,
          idempotency_id: "pay-#{invoice_id}-#{Time.now.to_i}",
          meta: {
            transaction_initiation_type: 'MIT',
            transaction_schedule_type: 'unscheduled'
          }
        })
        
        puts "Invoice paid successfully!"
        puts "Invoice ID: #{paid_invoice.id}"
        puts "Status: #{paid_invoice.status}"
        puts "Paid at: #{paid_invoice.paid_at}"
        puts "Total paid: $#{paid_invoice.total_paid_in_dollars}"
        puts "Balance due: $#{paid_invoice.balance_due_in_dollars}"
        
        # Display transaction details if available
        if paid_invoice.child_transactions && !paid_invoice.child_transactions.empty?
          transaction = paid_invoice.child_transactions.first
          puts "\nTransaction details:"
          puts "Transaction ID: #{transaction['id']}"
          puts "Type: #{transaction['type']}"
          puts "Method: #{transaction['method']}"
          puts "Success: #{transaction['success']}"
          puts "Total: $#{transaction['total'].to_f}"
        end
        puts
      end
    else
      puts "Invoice has no associated customer. Cannot pay invoice."
      puts
    end
  end
rescue => e
  puts "Error paying invoice: #{e.message}"
  puts
end

# Example: Pay an invoice with partial payment
puts "Paying an invoice with partial payment..."
begin
  # Get the most recent invoice that's in SENT status
  result = client.invoices(status: 'SENT', limit: 5)
  sent_invoices = result[:invoices].select { |inv| inv.is_partial_payment_enabled }
  
  if sent_invoices.empty?
    puts "No sent invoices found that allow partial payments."
  else
    invoice_id = sent_invoices.first.id
    invoice_total = sent_invoices.first.total_in_dollars
    partial_amount = (invoice_total / 2).round(2)  # Pay half the amount
    
    # Get payment method for the customer
    customer_id = sent_invoices.first.customer_id
    payment_methods = client.customer_payment_methods(customer_id) rescue []
    
    if payment_methods.empty?
      puts "No payment methods found for customer. Cannot pay invoice."
    else
      payment_method_id = payment_methods.first.id
      
      # Pay the invoice partially
      paid_invoice = client.pay_invoice(invoice_id, {
        payment_method_id: payment_method_id,
        email_receipt: true,
        apply_balance: partial_amount,
        idempotency_id: "partial-pay-#{invoice_id}-#{Time.now.to_i}"
      })
      
      puts "Invoice partially paid!"
      puts "Invoice ID: #{paid_invoice.id}"
      puts "Status: #{paid_invoice.status}"
      puts "Total: $#{paid_invoice.total_in_dollars}"
      puts "Amount paid: $#{partial_amount}"
      puts "Balance due: $#{paid_invoice.balance_due_in_dollars}"
      puts "Partially paid: #{paid_invoice.partially_paid? ? 'Yes' : 'No'}"
      puts
    end
  end
rescue => e
  puts "Error with partial payment: #{e.message}"
  puts
end

# Example: Delete an invoice
puts "Deleting an invoice..."
begin
  # Get the most recent invoice
  result = client.invoices(page: 2, limit: 1)  # Get from page 2 to avoid deleting our main example
  invoices = result[:invoices]
  
  if invoices.empty?
    puts "No invoices found to delete."
  else
    invoice_id = invoices.first.id
    
    # Delete the invoice
    deleted_invoice = client.delete_invoice(invoice_id)
    
    # Print the deleted invoice details
    puts "Invoice deleted successfully!"
    puts "Invoice ID: #{deleted_invoice.id}"
    puts "Status: #{deleted_invoice.status}"
    puts "Deleted at: #{deleted_invoice.deleted_at}"
    puts "Is deleted? #{deleted_invoice.deleted?}"
    
    # You can still access all the invoice properties
    puts "Customer: #{deleted_invoice.customer_name}"
    puts "Total: $#{deleted_invoice.total_in_dollars}"
    puts
  end
rescue StaxPayments::StaxError => e
  puts "Error: #{e.message}"
  puts "Status code: #{e.status_code}"
  puts "Error details: #{e.error_details}"
  puts
end

puts "=== Invoice Examples Completed ===" 