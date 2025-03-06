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
- Added `verify_payment_method` method to verify a payment method with a small pre-authorization
- Added `credit_payment_method` method to credit (refund) a payment method

### Changed
- Updated `delete_invoice` method to return the invoice object instead of a boolean value, matching the API documentation

## [0.1.0] - 2023-02-28

### Added
- Initial release
- Basic API client structure
- Support for Customers, Payments, Transactions, Cards, Bank Accounts
- Support for Invoices, Subscriptions, Plans, Refunds, Webhooks 