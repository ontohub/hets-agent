# frozen_string_literal: true

require 'spec_helper'
require 'support/bunnymock_recent_history_exchange'
require 'rest-client'

describe HetsRabbitMQWrapper do
  it 'has a version number' do
    expect(HetsRabbitMQWrapper::VERSION).not_to be nil
  end
end

describe HetsRabbitMQWrapper::Subscriber do

  let(:subscriber) { HetsRabbitMQWrapper::Subscriber.new(BunnyMock.new) }
  let(:queue) { subscriber.call }
  let(:session) { queue.channel.connection }

  context 'minimal parsing version queue' do
    it 'subscribe to' do
      expect(session.queue_exists?('q_min_parsing_version')).to be_truthy
    end
  end

  context 'worker queue' do
    before do
      allow(subscriber).
        to receive(:call_hets_version).and_return('v0.99, 1471209385')
      queue.publish('v0.99, 1471209385')
    end

    it 'subscribe to' do
      expect(session.queue_exists?('parsing-version-1471209385')).to be_truthy
    end

    it 'receives message' do
      session.queues['parsing-version-1471209385'].publish('Foobar')
    end
  end
end
