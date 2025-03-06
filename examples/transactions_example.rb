#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv/load'
require 'stax_payments'

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

puts "\nExample completed."