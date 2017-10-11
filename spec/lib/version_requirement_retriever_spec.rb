# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'

describe HetsAgent::VersionRequirementRetriever do
  before do
    # Stub the method that is tested here and all that follows
    allow(HetsAgent::Application).to receive(:initialize_version_requirement)
    allow(HetsAgent::Application).to receive(:initialize_version_available)

    # Only boot without running the test subject - see stub above
    boot_application(stub_version_requirement_retriever: false)
  end

  subject { HetsAgent::VersionRequirementRetriever.new }
  let(:bunny_mock) { HetsAgent::Application.bunny }

  context 'connection' do
    before do
      allow(bunny_mock).to receive(:start).and_call_original
      allow(bunny_mock).to receive(:close).and_call_original
      subject.call
    end

    it 'is started' do
      expect(bunny_mock).to have_received(:start)
    end

    it 'is closed' do
      expect(bunny_mock).to have_received(:close)
    end
  end

  context 'requirement' do
    let(:requirement) { 'requirement' }

    before do
      bunny_mock.start
      channel = bunny_mock.create_channel
      queue = channel.queue(subject.queue_name, auto_delete: true)
      queue.publish(requirement)
    end

    it 'is retrieved' do
      expect(subject.call).to eq(requirement)
    end
  end
end
