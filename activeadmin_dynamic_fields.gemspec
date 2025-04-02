# frozen_string_literal: true

$:.push File.expand_path('lib', __dir__)
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

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = Dir['{app,lib}/**/*', 'LICENSE.txt', 'Rakefile', 'README.md']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activeadmin', '>= 2.0', '< 4'
end
