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
