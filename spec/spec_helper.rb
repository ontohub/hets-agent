# frozen_string_literal: true

require_relative 'support/simplecov'

ENV['HETS_AGENT_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'hets-agent'
require 'bunny-mock'
require 'support/bunnymock_recent_history_exchange'
require 'fuubar'

Dir.glob('spec/support/**/*.rb').each do |file|
  require_relative file.sub(%r{\Aspec/}, '')
end

Dir.glob('spec/shared_examples/**/*.rb').each do |file|
  require_relative file.sub(%r{\Aspec/}, '')
end

RSpec.configure do |config|
  config.before(:suite) do
    HetsAgent::Subscriber.new(BunnyMock.new)
  end

  config.fuubar_progress_bar_options = {format: '[%B] %c/%C',
                                        progress_mark: '#',
                                        remainder_mark: '-'}
end
