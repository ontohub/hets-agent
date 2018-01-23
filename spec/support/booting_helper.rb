# frozen_string_literal: true

require 'ostruct'
require 'sneakers'

# Helper methods for booting the application
module BootingHelper
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def boot_application(hets_version_requirement: ['>= 1.2.3', '< 2.0.0'],
                       hets_version_available: '1.2.3',
                       stub_version_requirement_retriever: true)
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    if stub_version_requirement_retriever
      version_requirement_retriever = double(:version_requirement_retriever)
      allow(HetsAgent::VersionRequirementRetriever).
        to receive(:new).
        and_return(version_requirement_retriever)

      allow(version_requirement_retriever).
        to receive(:call).
        and_return(hets_version_requirement)
    end

    allow(HetsAgent::Hets::Caller).
      to receive(:call).
      with(instance_of(HetsAgent::Hets::VersionRequest)).
      and_return(OpenStruct.new(output: hets_version_available,
                                status: 0,
                                request: nil))

    HetsAgent::Application.boot

    allow(HetsAgent::Hets::Caller).
      to receive(:call).
      and_call_original

    stub_sneakers_logger
  end

  protected

  def stub_sneakers_logger
    logger = double(logger)
    allow(Sneakers).to receive(:logger).and_return(logger)
    %i(level= debug info warn error fatal).each do |method|
      allow(logger).to receive(method)
    end
  end
end

RSpec.configure do |config|
  config.include BootingHelper
end
