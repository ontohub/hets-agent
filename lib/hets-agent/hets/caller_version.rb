# frozen_string_literal: true

require 'hets-agent/hets/caller'

module HetsAgent
  module Hets
    # Provides an interface to call Hets and ask for the version
    class CallerVersion < Caller
      def call
        `#{hets_path} --numeric-version`.strip
      end
    end
  end
end
