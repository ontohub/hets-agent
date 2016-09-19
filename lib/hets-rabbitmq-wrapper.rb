# frozen_string_literal: true

require 'hets-rabbitmq-wrapper/version'
require 'bunny'

module HetsRabbitMQWrapper
  # Delivers queues for messages and decision which queues should be subscribed
  class Subscriber
    def initialize
      @connection = Bunny.new
    end

    def call
      @connection.start
      subscribe_min_parsing_version_queue
    ensure
      @connection.close
    end

    private

    # get version from HetsInstance
    def instance_version
      # TODO: get version from HetsInstance
    end

    # Binds queue to exchange and subscribes to mininmal parsing version queue
    def subscribe_min_parsing_version_queue
      q_min_parsing_version = min_parsing_version_queue
      q_min_parsing_version.bind('ex_min_parsing_version')
      q_min_parsing_version.
        subscribe(block: true,
                  timeout: 0) do |_delivery_info, _properties, version|
        subscribe_worker_queue(version)
      end
    end

    # Creates an exchange and a queue for minimal parsing version
    def min_parsing_version_queue
      channel = @connection.create_channel
      channel.exchange_declare('ex_min_parsing_version', 'x-recent-history',
                               'x-recent-history-length' => 1)
      channel.queue('q_min_parsing_version', durable: true, auto_delete: false)
    end

    # Subscribes to worker queue if min version is <= own version
    def subscribe_worker_queue(version)
      queues = create_worker_queue(version)
      if version.to_i <= instance_version.to_i
        queues[version.to_s].
          subscribe(block: false, manual_ack: true,
                    timeout: 0) do |delivery_info, _properties, _body|
          channel.ack(delivery_info.delivery_tag)
          # TODO: push body to hets
        end
      end
    end

    # Creates a worker queue depending on the min parsing version
    def create_worker_queue(version)
      channel = @connection.create_channel
      channel.prefetch(1)
      {version.to_s => channel.queue("parsing-version-#{version}",
                                     auto_delete: true)}
    end
  end
end
