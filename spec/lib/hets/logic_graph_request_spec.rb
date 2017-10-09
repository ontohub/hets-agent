# frozen_string_literal: true

require 'spec_helper'

describe HetsAgent::Hets::LogicGraphRequest do
  before do
    HetsAgent::Application.boot
  end

  subject { HetsAgent::Hets::LogicGraphRequest.new }

  context 'request' do
    it_behaves_like 'a HetsAgent::Hets::Request'
  end

  context 'arguments' do
    it 'logic graph' do
      expect(subject.arguments).to include('--logic-graph')
    end

    it 'output type' do
      expect(subject.arguments).to include('--output-types=db')
    end

    it 'database.yml' do
      database_yml = HetsAgent::Application.root.join('config/database.yml')
      expect(subject.arguments).
        to include("--database-config=#{database_yml}")
    end

    it 'database subconfig' do
      expect(subject.arguments).
        to include("--database-subconfig=#{HetsAgent::Application.env}")
    end

    it 'do not contain anything else' do
      expect(subject.arguments.length).to eq(5)
    end
  end
end
