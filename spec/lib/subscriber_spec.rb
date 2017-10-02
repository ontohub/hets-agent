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
  let(:queue_name) { "hets #{version_requirement}" }

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
      id = HetsAgent::Application.id
      expect(session.queue_exists?("q_hets_version_requirement-#{id}")).
        to be(true)
    end
  end

  context 'worker queue' do
    before do
      allow(subject).to receive(:call_hets_version).and_return(version)
      queue.publish(version_requirement)
    end

    context 'not satisfying the version requirement' do
      let(:version_requirement) { '~> 0.1.0, < 0.1.1' }
      it 'does not subscribe' do
        expect(session.queue_exists?(queue_name)).to be(false)
      end
    end

    context 'satisfying the version requirement' do
      it 'subscribes successfully' do
        expect(session.queue_exists?(queue_name)).to be(true)
      end

      it 'receives the message' do
        expect do
          session.queues[queue_name].publish({action: 'version'}.to_json)
        end.not_to raise_error
      end

      context 'version call' do
        before do
          expect_any_instance_of(HetsAgent::Hets::VersionCaller).
            to receive(:call)
        end

        let(:data) do
          {action: 'version'}.to_json
        end

        it 'receives the message' do
          session.queues[queue_name].publish(data)
        end
      end

      context 'analysis call' do
        before do
          allow(HetsAgent::Hets::AnalysisCaller).
            to receive(:new).and_call_original
          expect_any_instance_of(HetsAgent::Hets::AnalysisCaller).
            to receive(:call)
        end

        let(:data) do
          {
            'action' => 'analysis',
            'arguments' => arguments,
          }.to_json
        end
        let(:arguments) do
          {
            'server_url' => 'http://localhost:3000',
            'repository_slug' => 'ada/fixtures',
            'revision' => '4242be11ccc498c43904e2ce506c3306a27b9ca4',
            'file_path' => 'Hets-lib/Basic/RelationsAndOrders.casl',
            'file_version_id' => 23,
            'url_mappings' => {
              'Basic/' => 'Hets-lib/Basic/',
            },
          }
        end
        let(:symbolized_arguments) do
          args = {}
          arguments.each do |key, value|
            args[key.to_sym] = value
          end
          args
        end

        it 'receives the message' do
          session.queues[queue_name].publish(data)
          expect(HetsAgent::Hets::AnalysisCaller).
            to have_received(:new).
            with(symbolized_arguments)
        end
      end

      context 'unkown action' do
        before do
          allow(HetsAgent::Hets::AnalysisCaller).to receive(:new)
          allow(HetsAgent::Hets::VersionCaller).to receive(:new)
          session.queues[queue_name].publish(data)
        end

        let(:data) { {'action' => 'unkown'}.to_json }

        it 'does not call the AnalysisCaller' do
          expect(HetsAgent::Hets::AnalysisCaller).not_to have_received(:new)
        end

        it 'does not call the VersionCaller' do
          expect(HetsAgent::Hets::VersionCaller).not_to have_received(:new)
        end
      end
    end
  end
end