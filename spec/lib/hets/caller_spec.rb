# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'

describe HetsAgent::Hets::Caller do
  let(:request) { OpenStruct.new(arguments: ['executable', 'arg 1', 'arg 2']) }
  let(:output) { 'Lorem ipsum dolor sit' }
  let(:status) { 0 }

  before do
    HetsAgent::Application.boot
    allow(HetsAgent::Popen).to receive(:popen).and_return([output, status])
  end

  it 'calls popen' do
    expect(HetsAgent::Popen).to receive(:popen).with(request.arguments)
    HetsAgent::Hets::Caller.call(request)
  end

  it 'responds with a response' do
    expect(HetsAgent::Hets::Caller.call(request)).
      to be_a(HetsAgent::Hets::Response)
  end

  it 'has the correct output' do
    expect(HetsAgent::Hets::Caller.call(request).output).
      to eq(output)
  end

  it 'has the correct status' do
    expect(HetsAgent::Hets::Caller.call(request).status).
      to eq(status)
  end
end
