# frozen_string_literal: true

module HetsAgent
  module Hets
    # Forms an response of Hets
    class Response
      attr_reader :output, :request, :status

      def initialize(request, output, status)
        @request = request
        @output = output.strip
        @status = status
      end
    end
  end
end
