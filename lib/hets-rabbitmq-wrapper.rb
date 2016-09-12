# frozen_string_literal: true

require 'hets-rabbitmq-wrapper/version'
require 'bunny'

module HetsRabbitMQWrapper
  def self.run
    connection = Bunny.new
    connection.start

    min_parsing_version(connection)
  end

  def self.instance_version
    #get version from HetsInstance
  end

  def self.min_parsing_version(connection)
    channel = connection.create_channel
    channel.exchange_declare('ex_min_parsing_version', 'x-recent-history',
                             {'x-recent-history-length' => 1})
    q_min_parsing_version = channel.queue('q_min_parsing_version',
                                          durable: true, auto_delete: false)
    q_min_parsing_version.bind('ex_min_parsing_version')
    q_min_parsing_version.
      subscribe(block: false,
                timeout: 0) do |delivery_info, properties, version|
      subscribe(version, connection)
    end
  end

  def self.subscribe(version, connection)
    channel = connection.create_channel
    channel.prefetch(1)
    queues = Hash.new
    queues["#{version}"] = channel.queue("parsing-version-#{version}",
                                         auto_delete: true)
    puts queues["#{version}"]
    if version.to_i <= instance_version.to_i
      queues["#{version}"].
        subscribe(block: false, manual_ack: true,
                  timeout: 0) do |delivery_info, properties, body|
        channel.ack(delivery_info.delivery_tag)
        #push body to hets
      end
    end
  end
end
