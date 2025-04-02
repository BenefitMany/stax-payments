# frozen_string_literal: true

$LOAD_PATH.unshift(::File.join(::File.dirname(__FILE__), 'lib'))

require_relative 'lib/stax_payments/version'

Gem::Specification.new do |spec|
  spec.name          = 'stax_payments'
  spec.version       = StaxPayments::VERSION
  spec.authors       = ['Blake Campbell', 'Wes Hays']
  spec.email         = ['blake@benefitmany.com', 'wes@benefitmany.com']

  spec.summary       = 'API wrapper for the Stax Payments API'
  spec.description   = 'Stax Payments provides a RESTful API for payment processing. This gem is a wrapper for that API.'
  spec.homepage      = 'https://github.com/benefitmany/stax-payments'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.0')

  spec.metadata['source_code_uri'] = 'https://github.com/benefitmany/stax-payments'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/benefitmany/stax-payments/issues'
  spec.metadata['changelog_uri'] = 'https://github.com/benefitmany/stax-payments/blob/main/CHANGELOG.md'
  spec.metadata['documentation_uri'] = 'https://staxapi.docs.apiary.io/#'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'typhoeus', '~> 1.4'
  spec.add_dependency 'json', '~> 2.7'
  spec.add_dependency 'plissken', '~> 3.0'
  spec.add_dependency 'awrence', '~> 3.0'
  spec.add_dependency 'ostruct', '~> 0.6.1'
end
