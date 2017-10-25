# frozen_string_literal: true

require 'config'
require 'pathname'

module HetsAgent
  # The Application class encapsulates some basic properties.
  class Application
    ROOT = Pathname.new(File.expand_path('../../../', __FILE__)).freeze
    ENVIRONMENT = (ENV['HETS_AGENT_ENV'] || 'development').freeze

    class << self
      attr_reader :bunny, :hets_version_available, :hets_version_requirement

      def root
        ROOT
      end

      def env
        return @env if @env

        @env = ENVIRONMENT.dup
        %w(test development production).each do |e|
          @env.define_singleton_method("#{e}?") { ENVIRONMENT == e }
        end
        @env
      end

      def boot
        setting_files = ::Config.setting_files(root.join('config'), env)
        ::Config.load_and_set_settings(setting_files)

        normalize_paths
        initialize_bunny
        initialize_version_requirement
        initialize_version_available

        true
      end

      def id
        (ENV['HETS_AGENT_ID'] || Settings.agent.id).to_s
      end

      private

      def normalize_paths
        Settings.hets.path = Pathname.new(Settings.hets.path)
      end

      def initialize_bunny
        @bunny = Bunny.new(username: Settings.rabbitmq.username,
                           password: Settings.rabbitmq.password,
                           host: Settings.rabbitmq.host,
                           port: Settings.rabbitmq.port)
      end

      def initialize_version_requirement
        @hets_version_requirement =
          HetsAgent::VersionRequirementRetriever.new.call

        return unless hets_version_requirement.nil?

        message =
          ['No version requirement for Hets received.',
           'Please start the ontohub-backend and try again.'].join("\n")
        raise HetsAgent::BootingError, message
      end

      def initialize_version_available
        version_request = HetsAgent::Hets::VersionRequest.new
        @hets_version_available =
          HetsAgent::Hets::Caller.call(version_request).output

        unless Gem::Requirement.new(hets_version_requirement).
            satisfied_by?(Gem::Version.new(hets_version_available))
          message =
            "The available Hets version #{hets_version_available} does not "\
            "satisfy the requirement #{hets_version_requirement}."
          raise HetsAgent::IncompatibleVersionError, message
        end
      end
    end
  end
end
