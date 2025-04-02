#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry-byebug'
require 'dotenv/load'
require_relative '../lib/stax_payments'

Dotenv.load('../.env')

# Initialize the client
client = if ENV['STAX_API_KEY']
  StaxPayments::Client.new
else
  puts "ERROR: No API credentials found in environment variables."
  puts "Please set STAX_API_KEY and STAX_API_SECRET in your .env file."
  exit 1
end

puts "=== Stax Payments API - Transactions Example ==="
puts

# List recent transactions
puts "Fetching recent transactions..."
transactions = client.transactions(per_page: 5)

if transactions.is_a?(StaxPayments::StaxError)
  puts "Error fetching transactions: #{transactions.message}"
  exit 1
end

if transactions.empty?
  puts "No transactions found."
else
  puts "Found #{transactions.length} transactions:"
  transactions.each do |transaction|
    puts "- ID: #{transaction.id}"
    puts "  Amount: $#{transaction.amount_in_dollars}"
    puts "  Status: #{transaction.status}"
    puts "  Type: #{transaction.type}"
    puts "  Created: #{transaction.created_at}"
    puts
  end
end

# Get transaction details
if transactions.any?
  transaction_id = transactions.first.id
  puts "Fetching details for transaction #{transaction_id}..."
  transaction = client.transaction(transaction_id)

  if transaction.is_a?(StaxPayments::StaxError)
    puts "Error fetching transaction: #{transaction.message}"
  else
    puts "Transaction Details:"
    puts "- ID: #{transaction.id}"
    puts "- Amount: $#{transaction.amount_in_dollars}"
    puts "- Currency: #{transaction.currency}"
    puts "- Status: #{transaction.status}"
    puts "- Type: #{transaction.type}"
    puts "- Customer ID: #{transaction.customer_id}"
    puts "- Payment Method ID: #{transaction.payment_method_id}"
    puts "- Payment Method Type: #{transaction.payment_method_type}"
    puts "- Description: #{transaction.description}"
    puts "- Created At: #{transaction.created_at}"
    puts "- Updated At: #{transaction.updated_at}"
  end
end

# Search transactions
puts "\nSearching for completed transactions..."
search_results = client.search_transactions(
  status: 'completed',
  per_page: 3
)

if search_results.is_a?(StaxPayments::StaxError)
  puts "Error searching transactions: #{search_results.message}"
else
  puts "Found #{search_results.length} completed transactions:"
  search_results.each do |transaction|
    puts "- ID: #{transaction.id}"
    puts "  Amount: $#{transaction.amount_in_dollars}"
    puts "  Type: #{transaction.type}"
    puts "  Created: #{transaction.created_at}"
    puts
  end
end

# Get transaction summary (if available)
puts "Fetching transaction summary..."
begin
  summary = client.transaction_summary(
    start_date: (Date.today - 30).iso8601,
    end_date: Date.today.iso8601
  )

  if summary.is_a?(StaxPayments::StaxError)
    puts "Error fetching summary: #{summary.message}"
  else
    puts "Transaction Summary (Last 30 days):"
    puts "- Total Amount: $#{summary[:total_amount].to_f / 100}"
    puts "- Total Count: #{summary[:total_count]}"
    puts "- Average Amount: $#{summary[:average_amount].to_f / 100}"
  end
rescue => e
  puts "Error fetching summary: #{e.message}"
end

# Void a transaction example
puts "\nVoid Transaction Example:"
puts "Note: This example is commented out to prevent accidentally voiding a real transaction."
puts "To test this functionality, uncomment the code and provide a valid transaction ID."

# Uncomment the following code to test voiding a transaction
=begin
transaction_id = 'TRANSACTION_ID_TO_VOID' # Replace with a valid transaction ID
puts "Voiding transaction #{transaction_id}..."

begin
  result = client.void_transaction(transaction_id)

  if result.is_a?(StaxPayments::StaxError)
    puts "Error voiding transaction: #{result.message}"
    puts "Status code: #{result.status_code}"
    puts "Error details: #{result.error_details}"
  else
    puts "Transaction voided successfully!"
    puts "Transaction ID: #{result.id}"
    puts "Is Voided: #{result.is_voided ? 'Yes' : 'No'}"
    puts "Is Voidable: #{result.is_voidable ? 'Yes' : 'No'}"
    puts "Type: #{result.type}"
    puts "Status: #{result.success ? 'Success' : 'Failed'}"

    if result.child_transactions && !result.child_transactions.empty?
      puts "Child Transactions:"
      result.child_transactions.each do |child|
        puts "  - ID: #{child[:id]}"
        puts "    Type: #{child[:type]}"
        puts "    Success: #{child[:success] ? 'Yes' : 'No'}"
      end
    end
  end
rescue => e
  puts "Error: #{e.message}"
end
=end

# Refund a transaction example
puts "\nRefund Transaction Example:"
puts "Note: This example is commented out to prevent accidentally refunding a real transaction."
puts "To test this functionality, uncomment the code and provide a valid transaction ID."

# Uncomment the following code to test refunding a transaction
=begin
transaction_id = 'TRANSACTION_ID_TO_REFUND' # Replace with a valid transaction ID
refund_amount = 5.00 # Amount to refund in dollars
puts "Refunding $#{refund_amount} from transaction #{transaction_id}..."

begin
  result = client.refund_transaction(transaction_id, { total: refund_amount })

  if result.is_a?(StaxPayments::StaxError)
    puts "Error refunding transaction: #{result.message}"
    puts "Status code: #{result.status_code}"
    puts "Error details: #{result.error_details}"
  else
    puts "Transaction refunded successfully!"
    puts "Transaction ID: #{result.id}"
    puts "Total Amount: $#{result.total}"
    puts "Refunded Amount: $#{result.total_refunded}"
    puts "Is Refundable: #{result.is_refundable ? 'Yes' : 'No'}"
    puts "Type: #{result.type}"
    puts "Status: #{result.success ? 'Success' : 'Failed'}"

    if result.child_transactions && !result.child_transactions.empty?
      puts "Child Transactions:"
      result.child_transactions.each do |child|
        next unless child[:type] == 'refund'
        puts "  - ID: #{child[:id]}"
        puts "    Type: #{child[:type]}"
        puts "    Amount: $#{child[:total]}"
        puts "    Created: #{child[:created_at]}"
        puts "    Success: #{child[:success] ? 'Yes' : 'No'}"
      end
    end
  end
rescue => e
  puts "Error: #{e.message}"
end
=end

puts "\nExample completed."