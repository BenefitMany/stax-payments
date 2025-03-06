#!/usr/bin/env ruby
# frozen_string_literal: true

require 'dotenv/load'
require_relative '../lib/stax_payments'

# Initialize the Stax Payments client with API credentials
client = StaxPayments::Client.new

# =========================================
# Customer Examples
# =========================================

puts "=== Creating a Customer ==="
begin
  # Customer details based on Stax API documentation
  customer_params = {
    firstname: "John",
    lastname: "Smith",
    company: "ABC INC",
    email: "contact@example.com",
    cc_emails: ["demo@abc.com"],
    phone: "1234567898",
    address_1: "123 Rite Way",
    address_2: "Unit 12",
    address_city: "Orlando",
    address_state: "FL",
    address_zip: "32801",
    address_country: "USA",
    reference: "BARTLE"
  }
  
  # Create a new customer
  customer = client.create_customer(customer_params)
  
  puts "Customer created successfully:"
  puts "  ID: #{customer.id}"
  puts "  Name: #{customer.firstname} #{customer.lastname}"
  puts "  Company: #{customer.company}"
  puts "  Email: #{customer.email}"
  puts "  Phone: #{customer.phone}"
  puts "  Address: #{customer.address_1}, #{customer.address_2}"
  puts "  City: #{customer.address_city}"
  puts "  State: #{customer.address_state}"
  puts "  Zip: #{customer.address_zip}"
  puts "  Country: #{customer.address_country}"
  puts "  Reference: #{customer.reference}"
  puts "  Created: #{customer.created_at}"
  
  # Save the customer ID for later examples
  created_customer_id = customer.id
rescue => e
  puts "Error creating customer: #{e.message}"
end

puts "\n=== Retrieving a Customer (Success Case) ==="
begin
  # Use the ID of the customer we just created, or a known valid ID
  customer_id = created_customer_id || 'd45ee88c-8b27-4be8-8d81-77dda1b81826'
  
  # Get a specific customer
  customer = client.customer(customer_id)
  
  # Check if we got an error
  if customer.is_a?(StaxPayments::StaxError)
    puts "Error retrieving customer: #{customer.message}"
  else
    puts "Customer details:"
    puts "  ID: #{customer.id}"
    puts "  Name: #{customer.firstname} #{customer.lastname}"
    puts "  Company: #{customer.company}"
    puts "  Email: #{customer.email}"
    puts "  CC Emails: #{customer.cc_emails ? customer.cc_emails.join(', ') : 'None'}"
    puts "  Phone: #{customer.phone}"
    puts "  Address: #{customer.address_1}, #{customer.address_2}"
    puts "  City: #{customer.address_city}"
    puts "  State: #{customer.address_state}"
    puts "  Zip: #{customer.address_zip}"
    puts "  Country: #{customer.address_country}"
    puts "  Notes: #{customer.notes || 'None'}"
    puts "  Reference: #{customer.reference}"
    puts "  Options: #{customer.options || 'None'}"
    puts "  Created: #{customer.created_at}"
    puts "  Updated: #{customer.updated_at}"
    puts "  Deleted: #{customer.deleted_at || 'Not deleted'}"
    puts "  Gravatar: #{customer.gravatar}"
    puts "  Has Address: #{customer.has_address ? 'Yes' : 'No'}"
    puts "  Missing Address Components: #{customer.missing_address_components.empty? ? 'None' : customer.missing_address_components.join(', ')}"
    
    # Use helper methods
    puts "\nHelper method examples:"
    puts "  Full Name: #{customer.full_name}"
    puts "  Has Complete Address: #{customer.has_complete_address? ? 'Yes' : 'No'}"
    puts "  Is Deleted: #{customer.deleted? ? 'Yes' : 'No'}"
    puts "  Formatted Address:\n    #{customer.formatted_address.gsub("\n", "\n    ")}"
  end
rescue => e
  puts "Error retrieving customer: #{e.message}"
end

puts "\n=== Retrieving a Customer (Error Case) ==="
begin
  # Use an invalid customer ID
  invalid_customer_id = 'invalid_customer_id'
  
  # Try to get a non-existent customer
  customer = client.customer(invalid_customer_id)
  
  # Check if we got an error
  if customer.is_a?(StaxPayments::StaxError)
    puts "Error retrieving customer: #{customer.message}"
    puts "This is expected behavior for an invalid customer ID."
  else
    puts "Customer details (unexpected success):"
    puts "  ID: #{customer.id}"
    puts "  Name: #{customer.firstname} #{customer.lastname}"
    # ... other details would go here
  end
rescue => e
  puts "Error retrieving customer: #{e.message}"
end

puts "\n=== Updating a Customer (Success Case) ==="
begin
  # Use the ID of the customer we created earlier, or a known valid ID
  customer_id = created_customer_id || 'd45ee88c-8b27-4be8-8d81-77dda1b81826'
  
  # Update customer details based on Stax API documentation
  update_params = {
    firstname: "John",
    lastname: "Smith",
    company: "ABC INC",
    email: "demo@abc.com",
    cc_emails: ["demo1@abc.com", "demo2@abc.com"],
    phone: "1234567898",
    address_1: "123 Rite Way",
    address_2: "Unit 12",
    address_city: "Orlando",
    address_state: "FL",
    address_zip: "32801",
    address_country: "USA",
    reference: "BARTLE"
  }
  
  # Update the customer
  customer = client.update_customer(customer_id, update_params)
  
  # Check if we got an error
  if customer.is_a?(StaxPayments::StaxError)
    puts "Error updating customer: #{customer.message}"
  else
    puts "Customer updated successfully:"
    puts "  ID: #{customer.id}"
    puts "  Name: #{customer.firstname} #{customer.lastname}"
    puts "  Company: #{customer.company}"
    puts "  Email: #{customer.email}"
    puts "  CC Emails: #{customer.cc_emails ? customer.cc_emails.join(', ') : 'None'}"
    puts "  Phone: #{customer.phone}"
    puts "  Address: #{customer.address_1}, #{customer.address_2}"
    puts "  City: #{customer.address_city}"
    puts "  State: #{customer.address_state}"
    puts "  Zip: #{customer.address_zip}"
    puts "  Country: #{customer.address_country}"
    puts "  Reference: #{customer.reference}"
    puts "  Updated: #{customer.updated_at}"
    puts "  Gravatar: #{customer.gravatar}"
  end
rescue => e
  puts "Error updating customer: #{e.message}"
end

puts "\n=== Updating a Customer (Error Case) ==="
begin
  # Use an invalid customer ID
  invalid_customer_id = 'invalid_customer_id'
  
  # Update details for a non-existent customer
  update_params = {
    firstname: "Jane",
    lastname: "Doe"
  }
  
  # Try to update a non-existent customer
  customer = client.update_customer(invalid_customer_id, update_params)
  
  # Check if we got an error
  if customer.is_a?(StaxPayments::StaxError)
    puts "Error updating customer: #{customer.message}"
    puts "This is expected behavior for an invalid customer ID."
  else
    puts "Customer updated (unexpected success):"
    puts "  ID: #{customer.id}"
    puts "  Name: #{customer.firstname} #{customer.lastname}"
    # ... other details would go here
  end
rescue => e
  puts "Error updating customer: #{e.message}"
end

puts "\n=== Updating a Customer (Partial Update) ==="
begin
  # Use the ID of the customer we created earlier, or a known valid ID
  customer_id = created_customer_id || 'd45ee88c-8b27-4be8-8d81-77dda1b81826'
  
  # Update only specific fields
  partial_update_params = {
    email: "new.email@example.com",
    phone: "9876543210"
  }
  
  # Update the customer
  customer = client.update_customer(customer_id, partial_update_params)
  
  # Check if we got an error
  if customer.is_a?(StaxPayments::StaxError)
    puts "Error updating customer: #{customer.message}"
  else
    puts "Customer partially updated successfully:"
    puts "  ID: #{customer.id}"
    puts "  Name: #{customer.firstname} #{customer.lastname}"
    puts "  Email: #{customer.email}"
    puts "  Phone: #{customer.phone}"
    puts "  Updated: #{customer.updated_at}"
  end
rescue => e
  puts "Error updating customer: #{e.message}"
end

puts "\n=== Listing Customers (Basic) ==="
begin
  # List all customers (limited to 10 for this example)
  result = client.customers(per_page: 10)
  
  if result[:customers].empty?
    puts "No customers found"
  else
    puts "Found #{result[:customers].size} customers (Page #{result[:pagination][:current_page]} of #{result[:pagination][:last_page]}):"
    puts "Total customers: #{result[:pagination][:total]}"
    
    result[:customers].each do |customer|
      puts "  ID: #{customer.id}"
      puts "  Name: #{customer.firstname} #{customer.lastname}"
      puts "  Email: #{customer.email}"
      puts "  Created: #{customer.created_at}"
      puts "  --------"
    end
  end
rescue => e
  puts "Error listing customers: #{e.message}"
end

puts "\n=== Listing Customers with Filtering ==="
begin
  # Filter customers by various criteria
  filter_params = {
    firstname: "John",
    company: "ABC",
    address_state: "FL",
    per_page: 10
  }
  
  result = client.customers(filter_params)
  
  if result[:customers].empty?
    puts "No customers found matching the filter criteria"
  else
    puts "Found #{result[:customers].size} customers matching the filter criteria:"
    puts "Total matching customers: #{result[:pagination][:total]}"
    
    result[:customers].each do |customer|
      puts "  ID: #{customer.id}"
      puts "  Name: #{customer.firstname} #{customer.lastname}"
      puts "  Company: #{customer.company}"
      puts "  State: #{customer.address_state}"
      puts "  --------"
    end
  end
rescue => e
  puts "Error filtering customers: #{e.message}"
end

puts "\n=== Listing Customers with Sorting ==="
begin
  # Sort customers by created date in descending order
  sort_params = {
    sort_by: "created_at",
    order: "desc",
    per_page: 10
  }
  
  result = client.customers(sort_params)
  
  if result[:customers].empty?
    puts "No customers found"
  else
    puts "Found #{result[:customers].size} customers sorted by creation date (newest first):"
    
    result[:customers].each do |customer|
      puts "  ID: #{customer.id}"
      puts "  Name: #{customer.firstname} #{customer.lastname}"
      puts "  Created: #{customer.created_at}"
      puts "  --------"
    end
  end
rescue => e
  puts "Error sorting customers: #{e.message}"
end

puts "\n=== Searching Customers by Keywords ==="
begin
  # Search customers by keywords
  search_params = {
    keywords: ["example.com", "ABC"],
    per_page: 10
  }
  
  result = client.customers(search_params)
  
  if result[:customers].empty?
    puts "No customers found matching the search criteria"
  else
    puts "Found #{result[:customers].size} customers matching the search criteria:"
    puts "Total matching customers: #{result[:pagination][:total]}"
    
    result[:customers].each do |customer|
      puts "  ID: #{customer.id}"
      puts "  Name: #{customer.firstname} #{customer.lastname}"
      puts "  Email: #{customer.email}"
      puts "  Company: #{customer.company}"
      puts "  --------"
    end
  end
rescue => e
  puts "Error searching customers: #{e.message}"
end

puts "\n=== Pagination Example ==="
begin
  # Get the second page of customers, 5 per page
  pagination_params = {
    page: 2,
    per_page: 5
  }
  
  result = client.customers(pagination_params)
  
  puts "Page #{result[:pagination][:current_page]} of #{result[:pagination][:last_page]}"
  puts "Showing customers #{result[:pagination][:from]} to #{result[:pagination][:to]} of #{result[:pagination][:total]}"
  
  if result[:customers].empty?
    puts "No customers found on this page"
  else
    result[:customers].each do |customer|
      puts "  ID: #{customer.id}"
      puts "  Name: #{customer.firstname} #{customer.lastname}"
      puts "  --------"
    end
  end
  
  # Navigation links
  puts "Previous page: #{result[:pagination][:prev_page_url] || 'None'}"
  puts "Next page: #{result[:pagination][:next_page_url] || 'None'}"
rescue => e
  puts "Error with pagination: #{e.message}"
end

puts "\n=== Deleting a Customer ==="
begin
  # Use the ID of the customer we created earlier, or a known valid ID
  customer_id = created_customer_id || 'd45ee88c-8b27-4be8-8d81-77dda1b81826'
  
  # Delete the customer
  result = client.delete_customer(customer_id)
  
  if result
    puts "Customer deleted successfully"
  else
    puts "Failed to delete customer"
  end
rescue => e
  puts "Error deleting customer: #{e.message}"
end

puts "\n=== Customer Operations Complete ===" 