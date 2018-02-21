# frozen_string_literal: true

require 'hets-agent/application'

module HetsAgent
  # The Schema class to validate the Settings against
  class SettingsSchema < Dry::Validation::Schema
    configure do |config|
      config.messages_file = HetsAgent::Application.root.join(
        'config/settings_validation_errors.yml'
      )
    end

    def executable?(value)
      File.file?(value.to_s) && File.executable?(value.to_s)
    end

    define! do
      required(:hets).schema do
        required(:path).filled { str? & executable? }
      end

      required(:agent).schema do
        required(:id).filled
      end

      required(:backend).schema do
        required(:api_key).filled { str? }
      end

      required(:rabbitmq).schema do
        required(:host).filled { str? }
        required(:port).filled { int? }
        required(:username).filled { str? }
        required(:password).filled { str? }
        required(:virtual_host).filled { str? }
      end

      required(:sneakers).schema do
        required(:workers).filled(:int?)
      end
    end
  end
end
