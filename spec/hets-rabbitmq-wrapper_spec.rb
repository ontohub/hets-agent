# frozen_string_literal: true

require 'spec_helper'

describe HetsRabbitMQWrapper do
  it 'has a version number' do
    expect(HetsRabbitMQWrapper::VERSION).not_to be nil
  end
end

describe HetsRabbitMQWrapper::Subscriber do
  context 'minimal parsing version queue' do
    it 'subscribe to' do
      queue = HetsRabbitMQWrapper::Subscriber.new(BunnyMock.new).min_parsing_version_queue
      expect(session.queue_exists?('q_min_parsing_version')).to be_truthy
    end
  end
end
