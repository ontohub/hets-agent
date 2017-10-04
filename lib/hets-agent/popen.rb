# frozen_string_literal: true

require 'fileutils'
require 'open3'

module HetsAgent
  # A module to invoke system calls conveniently.
  module Popen
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def popen(cmd, working_dir = nil, vars = {})
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
      unless cmd.is_a?(Array)
        raise 'System commands must be given as an array of strings'
      end

      working_dir ||= Dir.pwd
      vars = vars.dup
      vars['PWD'] = working_dir
      options = {chdir: working_dir}

      FileUtils.mkdir_p(working_dir) unless File.directory?(working_dir)

      cmd_output = ''
      cmd_status = 0
      Open3.popen3(vars, *cmd, options) do |stdin, stdout, stderr, wait_thr|
        yield(stdin) if block_given?
        stdin.close

        cmd_output += stdout.read
        cmd_output += stderr.read
        cmd_status = wait_thr.value.exitstatus
      end

      [cmd_output, cmd_status]
    end

    module_function :popen
  end
end
