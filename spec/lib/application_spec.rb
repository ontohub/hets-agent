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
  end
end
