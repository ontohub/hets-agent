# frozen_string_literal: true

require 'hets-rabbitmq-wrapper/hets/caller'

module HetsRabbitMQWrapper
  module Hets
    # Provides an interface to call Hets and ask for the version
    class CallerVersion < Caller
      def call
        `#{hets_path} --numeric-version`.strip
      end
    end
  end
end
