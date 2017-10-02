# frozen_string_literal: true

require 'hets-agent/popen'
require 'hets-agent/hets/response'

module HetsAgent
  module Hets
    # Provides an interface to call Hets
    class Caller
      def self.call(request)
        HetsAgent::Hets::Response.
          new(*HetsAgent::Popen.popen(request.arguments))
      end
    end
  end
end
