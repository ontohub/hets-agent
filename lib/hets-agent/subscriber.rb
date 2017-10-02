# frozen_string_literal: true

require 'bunny'
require 'hets-agent/application'
require 'hets-agent/error'
require 'hets-agent/hets'
require 'hets-agent/version'
require 'json'
require 'rest-client'

module HetsAgent
  # Delivers queues for messages and decision which queues should be subscribed
  class Subscriber
    def initialize(connection = Bunny.new)
      @connection = connection
    end

    def call
      @connection.start
      subscribe_version_requirement_queue
    ensure
      @connection.close
    end

    # get version from HetsInstance and parse it
    def hets_version
      @hets_version ||= HetsAgent::Hets::VersionCaller.new.call
    end

    private

    # Binds queue to exchange and subscribes to mininmal parsing version queue
    def subscribe_version_requirement_queue
      q_version_requirement = version_requirement_queue
      q_version_requirement.bind('ex_hets_version_requirement')
      q_version_requirement.
        subscribe(block: true,
                  timeout: 0) do |_delivery_info, _properties, requirement|
        subscribe_worker_queue(requirement)
      end
    end

    # Creates an exchange and a queue for minimal parsing version
    def version_requirement_queue
      channel = @connection.create_channel
      channel.exchange('ex_hets_version_requirement',
                       type: 'x-recent-history',
                       durable: true,
                       arguments: {'x-recent-history-length' => 1})
      channel.queue("q_hets_version_requirement-#{HetsAgent::Application.id}",
                    auto_delete: true)
    end

    # Subscribes to worker queue if min version is <= own version
    def subscribe_worker_queue(requirement)
      return unless version_requirement_satisfied?(requirement)
      queue = create_worker_queue(requirement)
      print_listening(requirement) if print?
      queue.subscribe(block: false, manual_ack: true,
                      timeout: 0) do |delivery_info, _properties, body|
        if call_hets(JSON.parse(body))
          queue.channel.acknowledge(delivery_info.delivery_tag)
        end
      end
    end

    def version_requirement_satisfied?(requirement)
      Gem::Requirement.new(*requirement.split(',')).
        satisfied_by?(Gem::Version.new(hets_version))
    end

    # Creates a worker queue depending on the min parsing version
    def create_worker_queue(requirement)
      channel = @connection.create_channel
      channel.prefetch(1)
      channel.queue(worker_queue_name(requirement), auto_delete: true)
    end

    def worker_queue_name(requirement)
      "hets #{requirement}"
    end

    def call_hets(data)
      case data['action']
      when 'analysis'
        call_hets_analysis(data['arguments'])
      when 'version'
        HetsAgent::Hets::VersionCaller.new.call
      else
        $stderr.puts %(Unrecognized action: "#{data['action']}") if print?
        nil
      end
    end

    def call_hets_analysis(arguments)
      accepted_arguments =
        %i(file_path file_version_id repository_slug revision server_url
           url_mappings)
      symbolized_arguments = arguments.
        map { |key, value| [key.to_sym, value] }.to_h.
        select { |key, _value| accepted_arguments.include?(key) }
      HetsAgent::Hets::AnalysisCaller.new(symbolized_arguments).call
    end

    def print?
      !HetsAgent::Application.env.test?
    end

    def print_listening(requirement)
      # :nocov:
      id = HetsAgent::Application.id
      queue_name = worker_queue_name(requirement)
      $stderr.puts %(Worker #{id} listening to queue "#{queue_name}")
      # :nocov:
    end
  end
end
