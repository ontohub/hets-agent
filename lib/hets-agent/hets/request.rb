# frozen_string_literal: true

module HetsAgent
  module Hets
    # Forms an abstract request to Hets
    class Request
      attr_reader :hets_path

      def initialize
        @hets_path = Settings.hets.path.to_s
        @database_yml =
          HetsAgent::Application.root.join('config/database.yml')
        @env = HetsAgent::Application.env
      end

      # Override this in the subclass
      def arguments; end

      def to_s
        arguments.join(' ')
      end

      protected

      def argument_authorization
        key = Settings.backend.api_key
        "--http-request-header=Authorization: ApiKey #{key}"
      end

      def arguments_database
        [argument_database_output,
         argument_database_yml,
         argument_database_subconfig,
         argument_database_migration]
      end

      def argument_database_output
        '--output-types=db'
      end

      def argument_database_yml
        "--database-config=#{@database_yml}"
      end

      def argument_database_subconfig
        "--database-subconfig=#{@env}"
      end

      def argument_database_migration
        '--database-do-not-migrate'
      end
    end
  end
end
