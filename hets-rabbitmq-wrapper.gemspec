# frozen_string_literal: true
# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hets-rabbitmq-wrapper/version'

Gem::Specification.new do |spec|
  spec.name          = 'hets-rabbitmq-wrapper'
  spec.version       = HetsRabbitMQWrapper::VERSION
  spec.authors       = ['Ontohub Core Developers']
  spec.email         = ['ontohub-dev-l@ovgu.de']

  spec.summary       = 'RabbitMQ wrapper for Hets'
  spec.description   = 'RabbitMQ wrapper for Hets'
  spec.homepage      = 'https://github.com/ontohub/hets-rabbitmq-wrapper'

  # Prevent pushing this gem to RubyGems.org.
  unless spec.respond_to?(:metadata)
    raise "We don't want to publish this outside of the Ontohub project."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry', '~> 0.10.4'
  spec.add_development_dependency 'pry-rescue', '~> 1.4.4'
  spec.add_development_dependency 'pry-stack_explorer', '~> 0.4.9.2'
  spec.add_development_dependency 'pry-byebug', '~> 3.4.0'
  spec.add_development_dependency 'pry-coolline', '~> 0.2.5'
  spec.add_development_dependency 'awesome_print', '~> 1.7.0'

  spec.add_dependency 'bunny', '~> 2.5.1'
  spec.add_dependency 'rest-client', '~> 2.0.0'
end
