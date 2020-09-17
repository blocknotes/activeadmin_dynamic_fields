# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activeadmin/dynamic_fields/version'

Gem::Specification.new do |spec|
  spec.name          = 'activeadmin_dynamic_fields'
  spec.version       = ActiveAdmin::DynamicFields::VERSION
  spec.summary       = 'Dynamic fields for ActiveAdmin'
  spec.description   = 'An Active Admin plugin to add dynamic behaviors to fields'
  spec.license       = 'MIT'
  spec.authors       = ['Mattia Roccoberton']
  spec.email         = 'mat@blocknot.es'
  spec.homepage      = 'https://github.com/blocknotes/activeadmin_dynamic_fields'

  spec.files         = Dir['{app,lib}/**/*', 'LICENSE.txt', 'Rakefile', 'README.md']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activeadmin', '~> 2.0'

  spec.add_development_dependency 'activestorage', '~> 6.0.3.2'
  spec.add_development_dependency 'capybara', '~> 3.33.0'
  spec.add_development_dependency 'pry', '~> 0.13.1'
  spec.add_development_dependency 'puma', '~> 4.3.5'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.4.1'
  spec.add_development_dependency 'rspec-rails', '~> 4.0.1'
  spec.add_development_dependency 'rubocop', '~> 0.90.0'
  spec.add_development_dependency 'selenium-webdriver', '~> 3.142.7'
  spec.add_development_dependency 'sqlite3', '~> 1.4.2'
end
