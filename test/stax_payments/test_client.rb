# frozen_string_literal: true

require 'test_helper'

class TestClient < Minitest::Test
  def test_initialize_with_env_vars
    # Skip if environment variables are not set
    skip unless ENV['STAX_API_KEY']

    client = StaxPayments::Client.new
    assert_instance_of StaxPayments::Client, client
  end

  def test_initialize_with_manual_config
    client = StaxPayments::Client.new(
      api_key: 'test_key',
      api_secret: 'test_secret'
    )
    assert_instance_of StaxPayments::Client, client
  end

  def test_initialize_with_missing_config
    ENV.stub :[], nil do
      assert_raises StaxPayments::StaxError do
        StaxPayments::Client.new
      end
    end
  end
end