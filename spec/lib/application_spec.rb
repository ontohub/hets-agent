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

    context 'hets_version_requirement' do
      context 'not received' do
        it 'raises an error' do
          expect { boot_application(hets_version_requirement: nil) }.
            to raise_error(HetsAgent::BootingError,
                           /no version requirement .*received/i)
        end
      end
    end

    context 'hets_version_available' do
      context 'incompatible' do
        it 'raises an error' do
          expect { boot_application(hets_version_available: '2.0.0') }.
            to raise_error(HetsAgent::IncompatibleVersionError,
                           /does not satisfy the requirement/i)
        end
      end
    end
  end

  context 'after booting' do
    before do
      boot_application
    end

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
          ENV['HETS_AGENT_ID'] = @old_env
        end

        it 'have a valid hets.path' do
          expect(HetsAgent::Application.id).to eq('1337')
        end
      end
    end

    context 'bunny' do
      it 'was initialized' do
        expect(Bunny).
          to have_received(:new).
          with('amqp://tester:testing@::1:25672')
      end

      it 'is available' do
        expect(HetsAgent::Application.bunny).to be_a(BunnyMock::Session)
      end
    end

    context 'hets_version_requirement' do
      it 'is set' do
        expect(HetsAgent::Application.hets_version_requirement).
          not_to be(nil)
      end
    end
  end
end
