# frozen_string_literal: true

require 'hets-agent/hets/request'

module HetsAgent
  module Hets
    # Forms a request to export the Logic Graph for Hets
    class LogicGraphRequest < Request
      def arguments
        [
          hets_path,
          *arguments_database,
          '--logic-graph',
        ]
      end
    end
  end
end
