# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'hets-rabbitmq-wrapper'
require_relative 'support/simplecov'
require 'bunny-mock'

RSpec.configure do |config|
  config.before(:each) do
    HetsRabbitMQWrapper::Subscriber.new(BunnyMock.new)
  end
end