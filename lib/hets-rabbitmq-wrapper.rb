# rubocop:disable Style/FileName
# frozen_string_literal: true

require 'bunny'
require 'rest-client'
require 'hets-rabbitmq-wrapper/version'
require 'hets-rabbitmq-wrapper/application'
require 'hets-rabbitmq-wrapper/hets'
require 'hets-rabbitmq-wrapper/error'

module HetsRabbitMQWrapper
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
      @hets_version ||= parse_hets_version(call_hets_version)
    rescue Errno::ECONNREFUSED
      raise HetsRabbitMQWrapper::HetsUnreachableError, 'Hets unreachable'
    end

    private

    # call hets version, stubbed out in the tests
    # :nocov:
    def call_hets_version
      RestClient::Request.
        execute(method: :get,
                url: 'http://localhost:8000/version',
                timeout: 3).to_s
    end
    # :nocov:

    # parse hets version
    def parse_hets_version(version)
      version.match(/(\d+)\z/)[0].to_i
    rescue NoMethodError
      raise HetsRabbitMQWrapper::HetsVersionParsingError,
      'Could not parse Hets version'
    end

    # Binds queue to exchange and subscribes to mininmal parsing version queue
    def subscribe_min_parsing_version_queue
      q_min_parsing_version = min_parsing_version_queue
      q_min_parsing_version.bind('ex_min_parsing_version')
      q_min_parsing_version.
        subscribe(block: true,
                  timeout: 0) do |_delivery_info, _properties, min_version|
        subscribe_worker_queue(min_version)
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
    def subscribe_worker_queue(min_version)
      queues = create_worker_queue(min_version)
      return unless parse_hets_version(min_version) <= hets_version
      queues.
        subscribe(block: false, manual_ack: true,
                  timeout: 0) do |delivery_info, _properties, _body|
        queues.channel.acknowledge(delivery_info.delivery_tag)
        # TODO: push body to hets
      end
    end

    # Creates a worker queue depending on the min parsing version
    def create_worker_queue(min_version)
      channel = @connection.create_channel
      channel.prefetch(1)
      min_version = parse_hets_version(min_version)
      channel.queue("parsing-version-#{min_version}", auto_delete: true)
    end
  end
end
