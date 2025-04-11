require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    config.active_record.legacy_connection_handling = false if Gem::Version.new(Rails.version) < Gem::Version.new('7.1')

    config.before_configuration do
      ActiveSupport::Cache.format_version = 7.0 if Gem::Version.new(Rails.version) > Gem::Version.new('7.0')
    end
  end
end
