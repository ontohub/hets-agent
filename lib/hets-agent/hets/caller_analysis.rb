# frozen_string_literal: true

require 'hets-agent/hets/caller'

module HetsAgent
  module Hets
    # Provides an interface to call Hets and analyze a Document
    class CallerAnalysis < Caller
      attr_reader :additional_url_mappings, :commit_sha, :file_path,
        :file_version_id, :libdir, :repository_slug, :server_url

      # rubocop: disable Metrics/ParameterLists
      def initialize(commit_sha:, file_path:, file_version_id:,
                     repository_slug:, server_url:, url_mappings:)
        # rubocop: enable Metrics/ParameterLists
        super()
        @additional_url_mappings = url_mappings
        @commit_sha = commit_sha
        @file_path = file_path
        @file_version_id = file_version_id
        @repository_slug = repository_slug
        @server_url = server_url

        @libdir =
          File.join(server_url, repository_slug, 'revision', commit_sha, 'tree')
      end

      def call
        system(*arguments)
      end

      def arguments
        [hets_path,
         argument_verbosity,
         argument_database_output,
         argument_database_yml,
         argument_database_subconfig,
         argument_libdirs,
         argument_automatic_rule,
         argument_file_version_id,
         argument_url_catalog,
         argument_file_path]
      end

      protected

      def argument_verbosity
        '--verbose=5'
      end

      def argument_libdirs
        "--hets-libdirs=#{libdir}"
      end

      def argument_automatic_rule
        '--apply-automatic-rule'
      end

      def argument_file_version_id
        "--database-fileversion-id=#{file_version_id}"
      end

      def argument_url_catalog
        urls = url_mappings.map { |source, target| [source, target].join('=') }
        "--url-catalog=#{urls.join(',')}"
      end

      def argument_file_path
        File.join(libdir, file_path)
      end

      def url_mappings
        default_url_mappings.merge(@additional_url_mappings)
      end

      def default_url_mappings
        url_mappings = {}
        %w(tree documents).each do |namespace|
          url_mappings[File.join(server_url, repository_slug, namespace)] =
            File.join(server_url, repository_slug, 'revision', commit_sha,
                      namespace)
        end
        url_mappings
      end
    end
  end
end
