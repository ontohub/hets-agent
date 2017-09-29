# frozen_string_literal: true

require 'spec_helper'

describe HetsAgent::Subscriber do
  before do
    HetsAgent::Application.boot
  end

  subject { HetsAgent::Subscriber.new(BunnyMock.new) }
  let(:queue) { subject.call }
  let(:session) { queue.channel.connection }
  let(:version_requirement) { '~> 0.1.0' }
  let(:version) { '0.1.5' }
  let(:queue_name) { "hets-#{version_requirement}" }

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
      expect(session.queue_exists?('q_hets_version_requirement')).to be(true)
    end
  end

  context 'worker queue' do
    before do
      allow(subject).to receive(:call_hets_version).and_return(version)
      queue.publish(version_requirement)
    end

    context 'satisfying the version requirement' do
      it 'subscribes successfully' do
        expect(session.queue_exists?(queue_name)).to be(true)
      end

      it 'receives message' do
        session.queues[queue_name].publish('Foobar')
      end
    end

    context 'not satisfying the version requirement' do
      let(:version_requirement) { '~> 0.1.0, < 0.1.1' }
      it 'does not subscribe' do
        expect(session.queue_exists?(queue_name)).to be(false)
      end
    end
  end
end
