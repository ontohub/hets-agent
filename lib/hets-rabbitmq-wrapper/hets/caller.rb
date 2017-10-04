# frozen_string_literal: true

module HetsRabbitMQWrapper
  module Hets
    # Provides an interface to call Hets
    class Caller
      attr_reader :hets_path

      def initialize
        @hets_path = Settings.hets.path.to_s
        @database_yml =
          HetsRabbitMQWrapper::Application.root.join('config/database.yml')
        @env = HetsRabbitMQWrapper::Application.env
      end

      # Override this in the subclass
      def call; end

      protected

      def argument_database_yml
        "--database-config=#{@database_yml}"
      end

      def argument_database_subconfig
        "--database-subconfig=#{@env}"
      end

      def argument_database_output
        '--output-types=db'
      end
    end
  end
end
