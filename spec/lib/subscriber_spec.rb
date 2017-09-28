# frozen_string_literal: true

require 'spec_helper'

describe HetsAgent::Subscriber do
  subject { HetsAgent::Subscriber.new(BunnyMock.new) }
  let(:queue) { subject.call }
  let(:session) { queue.channel.connection }
  let(:version_requirement) { '~> 0.1.0' }
  let(:version) { '0.1.1' }
  let(:queue_name) { "parsing-version-#{version}" }

  before do
    allow_any_instance_of(HetsAgent::Hets::VersionCaller).
      to receive(:call).
      and_return(version)
  end

  context 'hets_version' do
    it 'has the correct version' do
      expect(subject.hets_version).to eq(version)
    end
  end

  context 'minimal parsing version queue' do
    it 'subscribe to' do
      expect(session.queue_exists?('q_min_parsing_version')).to be_truthy
    end
  end

  context 'worker queue' do
    before do
      allow(subject).
        to receive(:call_hets_version).and_return(version)
      queue.publish(version)
    end

    it 'subscribes successfully' do
      expect(session.queue_exists?(queue_name)).to be(true)
    end

    it 'receives message' do
      session.queues[queue_name].publish('Foobar')
    end
  end
end
