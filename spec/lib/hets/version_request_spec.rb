# frozen_string_literal: true

require 'spec_helper'

describe HetsAgent::Hets::VersionRequest do
  before do
    HetsAgent::Application.boot
  end

  context 'arugments' do
    it 'are correct' do
      expect(HetsAgent::Hets::VersionRequest.new.arguments).
        to eq([Settings.hets.path.to_s, '--numeric-version'])
    end
  end
end
