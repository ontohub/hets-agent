# frozen_string_literal: true

module HetsRabbitMQWrapper
  class Error < ::StandardError; end
  class HetsError < Error; end

  class HetsUnreachableError < HetsError; end
  class HetsVersionParsingError < HetsError; end
end
