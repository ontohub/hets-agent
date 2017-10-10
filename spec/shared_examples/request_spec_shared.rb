# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'a HetsAgent::Hets::Request' do
  context 'to_s' do
    it 'matches the arguments' do
      expect(subject.to_s).to eq(subject.arguments.join(' '))
    end
  end

  context 'arguments' do
    it 'start with the execuable' do
      expect(subject.arguments.first).to eq(Settings.hets.path.to_s)
    end
  end
end
