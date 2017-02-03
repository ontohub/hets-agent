# frozen_string_literal: true

require 'spec_helper'

describe HetsRabbitMQWrapper::Subscriber do
  let(:bunny_spy) { :bunny_spy }
  subject { HetsRabbitMQWrapper::Subscriber.new }

  context 'hets_version' do
    before do
      allow(Bunny).to receive(:new).and_return(bunny_spy)
      allow(subject).
        to receive(:call_hets_version).and_return('v0.99, 1471209385')
    end

    it 'parses the version correctly' do
      expect(subject.hets_version).to eq(1_471_209_385)
    end

    context 'unreachable hets' do
      before do
        allow(subject).
          to receive(:call_hets_version).and_raise(Errno::ECONNREFUSED)
      end

      it 'raises the correct error on unreachable hets' do
        expect { subject.hets_version }.
          to raise_error(HetsRabbitMQWrapper::HetsUnreachableError,
                         'Hets unreachable')
      end
    end

    context 'could not parse hets version' do
      before do
        allow(subject).
          to receive(:call_hets_version).and_return('I am not a version')
      end

      it 'raises the correct error on unparseable version' do
        expect { subject.hets_version }.
          to raise_error(HetsRabbitMQWrapper::HetsVersionParsingError,
                         'Could not parse Hets version')
      end
    end
  end
end
