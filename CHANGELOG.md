# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Added `send_invoice_email` method to send invoices via email with optional CC recipients
- Added `send_invoice_sms` method to send invoices via SMS with optional custom message
- Added `charge_payment_method` method to charge a payment method and create a transaction
- Added `capture_transaction` method to capture a pre-authorized transaction
- Added `void_transaction` method to void a transaction that hasn't been settled
- Added `refund_transaction` method to refund a transaction with a specific amount
- Added `verify_payment_method` method to verify a payment method with a small pre-authorization
- Added `credit_payment_method` method to credit (refund) a payment method
- Added payment methods functionality with the following methods:
  - `payment_methods` to list all payment methods for a merchant with filtering options
  - `payment_method` to get a specific payment method by ID
  - `customer_payment_methods` to list all payment methods for a specific customer using the dedicated endpoint
  - `delete_payment_method` to delete a payment method
  - `create_payment_method` to create a new card or bank payment method for a customer
  - `update_payment_method` to update an existing payment method's details
  - `share_payment_method` to share a payment method with a third party using a gateway token
  - `review_surcharge` to check surcharge information for a transaction before processing it
- Enhanced `PaymentMethod` model with support for meta data and bin type information, including helper methods for card display, routing display, account display, and card type (debit/credit)

### Changed
- Updated `delete_invoice` method to return the invoice object instead of a boolean value, matching the API documentation
- Updated `delete_payment_method` method to return the payment method object instead of a boolean value, matching the API documentation

## [0.1.0] - 2023-02-28

### Added
- Initial release
- Basic API client structure
- Support for Customers, Payments, Transactions, Cards, Bank Accounts
- Support for Invoices, Subscriptions, Plans, Refunds, Webhooks 