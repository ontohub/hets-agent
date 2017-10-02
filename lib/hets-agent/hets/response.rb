# frozen_string_literal: true

module HetsAgent
  module Hets
    # Forms an response of Hets
    class Response
      attr_reader :output, :status

      def initialize(output, status)
        @output = output.strip
        @status = status
      end
    end
  end
end
