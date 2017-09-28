# frozen_string_literal: true

require 'bunny'
require 'hets-agent/application'
require 'hets-agent/error'
require 'hets-agent/hets'
require 'hets-agent/version'
require 'rest-client'

module HetsAgent
  # Delivers queues for messages and decision which queues should be subscribed
  class Subscriber
    def initialize(connection = Bunny.new)
      @connection = connection
    end

    def call
      @connection.start
      subscribe_min_parsing_version_queue
    ensure
      @connection.close
    end

    # get version from HetsInstance and parse it
    def hets_version
      @hets_version ||= HetsAgent::Hets::VersionCaller.new.call
    end

    private

    # Binds queue to exchange and subscribes to mininmal parsing version queue
    def subscribe_min_parsing_version_queue
      q_min_parsing_version = min_parsing_version_queue
      q_min_parsing_version.bind('ex_min_parsing_version')
      q_min_parsing_version.
        subscribe(block: true,
                  timeout: 0) do |_delivery_info, _properties, requirement|
        subscribe_worker_queue(requirement)
      end
    end

    # Creates an exchange and a queue for minimal parsing version
    def min_parsing_version_queue
      channel = @connection.create_channel
      channel.exchange('ex_min_parsing_version',
                       type: 'x-recent-history',
                       arguments: {'x-recent-history-length' => 1})
      channel.queue('q_min_parsing_version', durable: true, auto_delete: false)
    end

    # Subscribes to worker queue if min version is <= own version
    def subscribe_worker_queue(requirement)
      queues = create_worker_queue(requirement)
      unless Gem::Requirement.new(*requirement.split(',')).
          satisfied_by?(Gem::Version.new(hets_version))
        return
      end
      queues.
        subscribe(block: false, manual_ack: true,
                  timeout: 0) do |delivery_info, _properties, _body|
        queues.channel.acknowledge(delivery_info.delivery_tag)
        # TODO: push body to hets
      end
    end

    # Creates a worker queue depending on the min parsing version
    def create_worker_queue(requirement)
      channel = @connection.create_channel
      channel.prefetch(1)
      channel.queue("parsing-version-#{requirement}", auto_delete: true)
    end
  end
end
