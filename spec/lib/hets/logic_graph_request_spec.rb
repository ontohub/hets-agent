# frozen_string_literal: true

require 'spec_helper'

describe HetsAgent::Hets::LogicGraphRequest do
  before do
    boot_application
  end

  subject { HetsAgent::Hets::LogicGraphRequest.new }

  it_behaves_like 'a HetsAgent::Hets::Request'
  it_behaves_like 'a database request'

  context 'arguments' do
    it 'logic graph' do
      expect(subject.arguments).to include('--logic-graph')
    end

    it 'do not contain anything else' do
      expect(subject.arguments.length).to eq(6)
    end
  end
end
