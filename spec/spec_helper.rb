# frozen_string_literal: true

require_relative 'support/simplecov'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'hets-rabbitmq-wrapper'
require 'bunny-mock'

RSpec.configure do |config|
  config.before(:suite) do
    HetsRabbitMQWrapper::Subscriber.new(BunnyMock.new)
  end
end
