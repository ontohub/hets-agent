# frozen_string_literal: true

require 'spec_helper'
require 'hets-agent/worker'
require 'ostruct'

describe HetsAgent::Worker do
  before do
    boot_application
    allow(Sneakers).to receive(:publish)
  end

  subject { HetsAgent::Worker.new }
  let(:message) { 'message'.to_json }

  context 'result' do
    before do
      allow(subject).to receive(:ack!).and_call_original
      allow(subject).to receive(:reject!).and_call_original
    end

    context 'success' do
      before do
        allow(subject).
          to receive(:call_hets).
          and_return(OpenStruct.new(status: 0))
        subject.work(message)
      end

      it 'calls ack!' do
        expect(subject).to have_received(:ack!)
      end

      it 'does not call reject!' do
        expect(subject).not_to have_received(:reject!)
      end

      it 'publishes a job' do
        job = {job_class: 'PostProcessHetsJob',
               arguments: [:success, message]}
        expect(Sneakers).
          to have_received(:publish).
          with(job.to_json, to_queue: :post_process_hets)
      end
    end

    context 'failure' do
      before do
        allow(subject).
          to receive(:call_hets).
          and_return(OpenStruct.new(status: 1))
        subject.work(message)
      end

      it 'does not call ack!' do
        expect(subject).not_to have_received(:ack!)
      end

      it 'calls reject!' do
        expect(subject).to have_received(:reject!)
      end

      it 'does not publish a job' do
        expect(Sneakers).not_to have_received(:publish)
      end
    end
  end

  context 'actual work' do
    before do
      allow(HetsAgent::Hets::Caller).to receive(:call)
      allow(request_class).
        to receive(:new).and_call_original
      subject.work(data)
    end

    context 'analysis' do
      let(:request_class) { HetsAgent::Hets::AnalysisRequest }

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
          'url_mappings' => [{
            'Basic/' => 'Hets-lib/Basic/',
          }],
        }
      end
      let(:symbolized_arguments) do
        args = {}
        arguments.each do |key, value|
          args[key.to_sym] = value
        end
        args
      end

      it 'creates the request' do
        expect(request_class).
          to have_received(:new).
          with(symbolized_arguments)
      end

      it 'calls the Caller with a request' do
        expect(HetsAgent::Hets::Caller).
          to have_received(:call).
          with(instance_of(request_class))
      end
    end

    context 'migrate logic-graph' do
      let(:request_class) { HetsAgent::Hets::LogicGraphRequest }

      let(:data) do
        {
          'action' => 'migrate logic-graph',
        }.to_json
      end

      it 'creates the request' do
        expect(request_class).
          to have_received(:new).
          with(no_args)
      end

      it 'calls the Caller with a request' do
        expect(HetsAgent::Hets::Caller).
          to have_received(:call).
          with(instance_of(request_class))
      end
    end

    context 'version' do
      let(:request_class) { HetsAgent::Hets::VersionRequest }

      let(:data) do
        {
          'action' => 'version',
        }.to_json
      end

      it 'creates the request' do
        expect(request_class).
          to have_received(:new).
          with(no_args)
      end

      it 'calls the Caller with a request' do
        # The version request is also called at booting time
        expect(HetsAgent::Hets::Caller).
          to have_received(:call).
          with(instance_of(request_class)).twice
      end
    end

    context 'unknown' do
      let(:request_class) { HetsAgent::Hets::VersionRequest }
      let(:data) do
        {
          'action' => 'unknown',
        }.to_json
      end

      it 'does not call the Caller' do
        # The booting process calls it for the version
        expect(HetsAgent::Hets::Caller).to have_received(:call).once
      end
    end
  end
end
