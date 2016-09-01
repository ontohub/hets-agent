require 'hets-rabbitmq-wrapper/version'
require 'bunny'

module HetsRabbitMQWrapper
  def self.run
    connection = Bunny.new
    connection.start
    channel = connection.create_channel
    #worker will only accept one message at time
    channel.prefetch(1)
    request_queue = channel.queue('hets-request', durable: true, auto_delete: false)
    result_queue = channel.queue('hets-result')

    request_queue.subscribe(manual_ack: true, block: true, timeout: 0) do |delivery_info, properties, body|
      #todo: push body to hets
      channel.ack(delivery_info.delivery_tag)
    end
  end
end
