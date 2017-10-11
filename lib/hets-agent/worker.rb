# frozen_string_literal: true

require 'json'
require 'sneakers'

module HetsAgent
  # Waits for jobs and executes them. Make sure the application has booted
  # before loading this class. Otherwise the queue name will not be set
  # properly.
  class Worker
    include Sneakers::Worker
    from_queue "hets #{HetsAgent::Application.hets_version_requirement}",
               timeout_job_after: nil

    def work(message)
      response = call_hets(JSON.parse(message))
      if response&.status&.zero?
        ack!
      else
        reject!
      end
    end

    protected

    # rubocop:disable Metrics/MethodLength
    def call_hets(data)
      # rubocop:enable Metrics/MethodLength
      case data['action']
      when 'analysis'
        call_hets_analysis(data['arguments'])
      when 'migrate logic-graph'
        call_hets_logic_graph(data['arguments'])
      when 'version'
        call_hets_version(data['arguments'])
      else
        unless HetsAgent::Application.env.test?
          # :nocov:
          worker_trace %(Unrecognized action: "#{data['action']}")
          # :nocov:
        end
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
      HetsAgent::Hets::Caller.
        call(HetsAgent::Hets::AnalysisRequest.new(symbolized_arguments))
    end

    def call_hets_logic_graph(_arguments)
      HetsAgent::Hets::Caller.call(HetsAgent::Hets::LogicGraphRequest.new)
    end

    def call_hets_version(_arguments)
      HetsAgent::Hets::Caller.call(HetsAgent::Hets::VersionRequest.new)
    end
  end
end
