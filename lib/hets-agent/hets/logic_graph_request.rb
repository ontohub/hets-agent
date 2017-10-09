# frozen_string_literal: true

require 'hets-agent/hets/request'

module HetsAgent
  module Hets
    # Forms a request to export the Logic Graph for Hets
    class LogicGraphRequest < Request
      def arguments
        [
          hets_path,
          argument_database_output,
          argument_database_yml,
          argument_database_subconfig,
          '--logic-graph',
        ]
      end
    end
  end
end
