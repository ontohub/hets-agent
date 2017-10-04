# frozen_string_literal: true

require 'hets-agent/hets/request'

module HetsAgent
  module Hets
    # Forms a version request to Hets
    class VersionRequest < Request
      def arguments
        [hets_path, '--numeric-version']
      end
    end
  end
end
