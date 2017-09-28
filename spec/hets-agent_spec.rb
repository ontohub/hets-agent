# rubocop:disable Style/FileName
# frozen_string_literal: true

require 'spec_helper'
require 'support/bunnymock_recent_history_exchange'
require 'rest-client'

describe HetsAgent do
  it 'has a version number' do
    expect(HetsAgent::VERSION).not_to be nil
  end
end

describe HetsAgent::Subscriber do
  let(:subscriber) { HetsAgent::Subscriber.new(BunnyMock.new) }
  let(:queue) { subscriber.call }
  let(:session) { queue.channel.connection }

  context 'minimal parsing version queue' do
    it 'subscribe to' do
      expect(session.queue_exists?('q_min_parsing_version')).to be_truthy
    end
  end

  context 'worker queue' do
    let(:version_timestamp) { 1_471_209_385 }
    let(:version) { "v0.99, #{version_timestamp}" }
    before do
      allow(subscriber).
        to receive(:call_hets_version).and_return(version)
      queue.publish(version)
    end

    it 'subscribes successfully' do
      expect(session.queue_exists?('parsing-version-1471209385')).to be_truthy
    end

    it 'receives message' do
      session.queues['parsing-version-1471209385'].publish('Foobar')
    end
  end
end
