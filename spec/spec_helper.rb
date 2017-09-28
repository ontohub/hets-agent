# frozen_string_literal: true

require_relative 'support/simplecov'

ENV['HETS_RABBITMQ_WRAPPER_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'hets-agent'
require 'bunny-mock'

RSpec.configure do |config|
  config.before(:suite) do
    HetsAgent::Subscriber.new(BunnyMock.new)
  end
end
