# frozen_string_literal: true

require 'spec_helper'

describe HetsAgent::Hets::Response do
  let(:output) { 'Lorem ipsum dolor sit' }
  let(:status) { 0 }
  subject { HetsAgent::Hets::Response.new("#{output}\n", status) }

  it 'has a stripped output' do
    expect(subject.output).to eq(output)
  end

  it 'has a status' do
    expect(subject.status).to eq(status)
  end
end
