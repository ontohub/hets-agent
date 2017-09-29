# frozen_string_literal: true

require 'config'
require 'pathname'

module HetsAgent
  # The Application class encapsulates some basic properties.
  class Application
    ROOT = Pathname.new(File.expand_path('../../../', __FILE__)).freeze
    ENVIRONMENT = (ENV['HETS_AGENT_ENV'] || 'development').freeze

    class << self
      def root
        ROOT
      end

      def env
        environment = ENVIRONMENT.dup
        %w(test development production).each do |e|
          environment.define_singleton_method("#{e}?") { ENVIRONMENT == e }
        end
        environment
      end

      def boot
        setting_files = ::Config.setting_files(root.join('config'), env)
        ::Config.load_and_set_settings(setting_files)

        normalize_paths
        true
      end

      def id
        (ENV['HETS_AGENT_ID'] || Settings.agent.id).to_s
      end

      private

      def normalize_paths
        Settings.hets.path = Pathname.new(Settings.hets.path)
      end
    end
  end
end
