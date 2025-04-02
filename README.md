# Stax Payments

This gem is a wrapper for the Stax Payments API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stax_payments'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install stax_payments
```

## Usage

### Configuration

You can configure the client with your API credentials in two ways:

#### Environment Variables

Set the following environment variables:

```
STAX_API_KEY=your_api_key
```

Then initialize the client:

```ruby
client = StaxPayments::Client.new
```

#### Manual Configuration

```ruby
client = StaxPayments::Client.new(
  api_key: 'your_api_key',
  api_secret: 'your_api_secret'
)
```

### Examples

#### Customers

```ruby
# List all customers
customers = client.customers

# Get a specific customer
customer = client.customer('customer_id')

# Create a customer
new_customer = client.create_customer(
  first_name: 'John',
  last_name: 'Doe',
  email: 'john.doe@example.com'
)

# Update a customer
updated_customer = client.update_customer('customer_id',
  email: 'new.email@example.com'
)

# Delete a customer
client.delete_customer('customer_id')
```

#### Payments

```ruby
# List all payments
payments = client.payments

# Get a specific payment
payment = client.payment('payment_id')

# Create a payment
new_payment = client.create_payment(
  customer_id: 'customer_id',
  amount: 1000, # $10.00
  currency: 'USD',
  payment_method_id: 'card_id'
)

# Capture an authorized payment
captured_payment = client.capture_payment('payment_id')

# Void a payment
voided_payment = client.void_payment('payment_id')
```

#### Cards

```ruby
# List all cards for a customer
cards = client.customer_cards('customer_id')

# Get a specific card
card = client.customer_card('customer_id', 'card_id')

# Create a card
new_card = client.create_customer_card('customer_id',
  card_number: '4242424242424242',
  expiration_month: 12,
  expiration_year: 2025,
  cvv: '123'
)

# Update a card
updated_card = client.update_customer_card('customer_id', 'card_id',
  expiration_month: 11,
  expiration_year: 2026
)

# Delete a card
client.delete_customer_card('customer_id', 'card_id')
```

## Development

You will need to add a .env file to the root of the project with the following variables:

```
STAX_API_KEY=your_api_key
```

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to rubygems.org.

## Implemented Endpoints

* Customers
  * List `GET /customers`
  * View `GET /customers/:customer_id`
  * Create `POST /customers`
  * Update `PUT /customers/:customer_id`
  * Delete `DELETE /customers/:customer_id`
* Payments
  * List `GET /payments`
  * View `GET /payments/:payment_id`
  * Create `POST /payments`
  * Capture `POST /payments/:payment_id/capture`
  * Void `POST /payments/:payment_id/void`
* Transactions
  * List `GET /transactions`
  * View `GET /transactions/:transaction_id`
  * Search `POST /transactions/search`

## TODO Endpoints

* Cards
  * List `GET /customers/:customer_id/cards`
  * View `GET /customers/:customer_id/cards/:card_id`
  * Create `POST /customers/:customer_id/cards`
  * Update `PUT /customers/:customer_id/cards/:card_id`
  * Delete `DELETE /customers/:customer_id/cards/:card_id`
* Bank Accounts
  * List `GET /customers/:customer_id/bank_accounts`
  * View `GET /customers/:customer_id/bank_accounts/:bank_account_id`
  * Create `POST /customers/:customer_id/bank_accounts`
  * Update `PUT /customers/:customer_id/bank_accounts/:bank_account_id`
  * Delete `DELETE /customers/:customer_id/bank_accounts/:bank_account_id`
  * Verify `POST /customers/:customer_id/bank_accounts/:bank_account_id/verify`
* Invoices
  * List `GET /invoices`
  * View `GET /invoices/:invoice_id`
  * Create `POST /invoices`
  * Update `PUT /invoices/:invoice_id`
  * Delete `DELETE /invoices/:invoice_id`
  * Send `POST /invoices/:invoice_id/send`
  * Pay `POST /invoices/:invoice_id/pay`
* Subscriptions
  * List `GET /subscriptions`
  * View `GET /subscriptions/:subscription_id`
  * Create `POST /subscriptions`
  * Update `PUT /subscriptions/:subscription_id`
  * Cancel `POST /subscriptions/:subscription_id/cancel`
* Plans
  * List `GET /plans`
  * View `GET /plans/:plan_id`
  * Create `POST /plans`
  * Update `PUT /plans/:plan_id`
  * Delete `DELETE /plans/:plan_id`
* Refunds
  * List `GET /refunds`
  * View `GET /refunds/:refund_id`
  * Create `POST /refunds`
* Webhooks
  * List `GET /webhooks`
  * View `GET /webhooks/:webhook_id`
  * Create `POST /webhooks`
  * Update `PUT /webhooks/:webhook_id`
  * Delete `DELETE /webhooks/:webhook_id`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/benefitmany/stax-payments. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the code of conduct.

## License

The gem is available as open source under the terms of the MIT License.

## Code of Conduct

Everyone interacting in the stax_payments project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the code of conduct.
