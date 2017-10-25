# frozen_string_literal: true

require 'spec_helper'

describe HetsAgent::Hets::VersionRequest do
  before do
    boot_application
  end

  subject { HetsAgent::Hets::LogicGraphRequest.new }

  context 'request' do
    it_behaves_like 'a HetsAgent::Hets::Request'
  end

  context 'arguments' do
    it 'are correct' do
      expect(HetsAgent::Hets::VersionRequest.new.arguments).
        to eq([Settings.hets.path.to_s, '--numeric-version'])
    end
  end
end
