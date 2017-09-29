# frozen_string_literal: true

require 'spec_helper'

describe HetsAgent::Application do
  context 'before booting' do
    it 'there are no settings' do
      expect { Settings }.to raise_error(NameError)
    end

    it 'has the correct root' do
      expect(HetsAgent::Application.root).
        to eq(Pathname.new(File.expand_path('../../..', __FILE__)))
    end

    it 'the environment string is set' do
      expect(HetsAgent::Application.env).to eq('test')
    end

    it 'the environment method test? is setup' do
      expect(HetsAgent::Application.env.test?).to be(true)
    end

    it 'the environment method development? is setup' do
      expect(HetsAgent::Application.env.development?).to be(false)
    end

    it 'the environment method production? is setup' do
      expect(HetsAgent::Application.env.production?).to be(false)
    end
  end

  context 'after booting' do
    before { HetsAgent::Application.boot }

    context 'settings' do
      it 'have a valid hets.path' do
        expect(Settings.hets.path).to be_a(Pathname)
      end
    end

    context 'id' do
      context 'without environment variable' do
        it 'have a valid hets.path' do
          expect(HetsAgent::Application.id).to eq('4711')
        end
      end

      context 'with the environment variable' do
        before do
          @old_env = ENV['HETS_AGENT_ID']
          ENV['HETS_AGENT_ID'] = '1337'
        end

        after do
          if @old_env.nil?
            ENV.delete('HETS_AGENT_ID')
          else
            ENV['HETS_AGENT_ID'] = @old_env
          end
        end

        it 'have a valid hets.path' do
          expect(HetsAgent::Application.id).to eq('1337')
        end
      end
    end
  end
end
