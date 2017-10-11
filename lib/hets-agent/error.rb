# frozen_string_literal: true

module HetsAgent
  class Error < ::StandardError; end
  class BootingError < Error; end
  class IncompatibleVersionError < Error; end
end
