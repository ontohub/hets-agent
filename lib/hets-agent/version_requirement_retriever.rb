# frozen_string_literal: true

require 'bunny'

module HetsAgent
  # Retrieves the version requirement of Hets from the backend.
  class VersionRequirementRetriever
    EXCHANGE_NAME = 'ex_hets_version_requirement'

    attr_reader :connection

    def initialize
      @connection = HetsAgent::Application.bunny
    end

    def call
      retrieve_version_requirement
    end

    def queue_name
      "hets_version_requirement-#{HetsAgent::Application.id}"
    end

    protected

    def retrieve_version_requirement
      received_requirement = nil
      connected do |channel|
        link_to_exchange(channel)
        queue = setup_version_requirement_queue(channel)
        queue.subscribe do |_delivery_info, _properties, requirement|
          received_requirement = requirement
        end
      end
      received_requirement
    end

    def link_to_exchange(channel)
      channel.exchange(EXCHANGE_NAME,
                       type: 'x-recent-history',
                       durable: true,
                       arguments: {'x-recent-history-length' => 1})
    end

    def setup_version_requirement_queue(channel)
      queue = channel.queue(queue_name, auto_delete: true)
      queue.bind(EXCHANGE_NAME)
      queue
    end

    def connected
      connection.start
      yield(connection.create_channel)
    ensure
      connection.close
    end
  end
end
