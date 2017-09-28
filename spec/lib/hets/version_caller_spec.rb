# frozen_string_literal: true

require 'spec_helper'

describe HetsAgent::Hets::VersionCaller do
  before do
    HetsAgent::Application.boot
  end

  context 'mocking the system call' do
    before do
      allow_any_instance_of(Kernel).
        to receive(:`).
        with("#{Settings.hets.path} --numeric-version").
        and_return("0.1.0\n")
    end

    it 'gets the version of Hets' do
      expect(HetsAgent::Hets::VersionCaller.new.call).to eq('0.1.0')
    end
  end
end
