# frozen_string_literal: true
# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hets-agent/version'

Gem::Specification.new do |spec|
  spec.name          = 'hets-agent'
  spec.version       = HetsAgent::VERSION
  spec.authors       = ['Ontohub Core Developers']
  spec.email         = ['ontohub-dev-l@ovgu.de']

  spec.summary       = 'An agent wrapping Hets'
  spec.description   = 'An agent wrapping Hets'
  spec.homepage      = 'https://github.com/ontohub/hets-agent'

  # Prevent pushing this gem to RubyGems.org.
  unless spec.respond_to?(:metadata)
    raise "We don't want to publish this outside of the Ontohub project."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec|features|Gemfile)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'bunny-mock', '~> 1.7.0'
  spec.add_development_dependency 'fuubar', '~> 2.3.0'
  spec.add_development_dependency 'rake', '~> 12.3.0'
  spec.add_development_dependency 'rspec', '~> 3.7.0'

  spec.add_development_dependency 'codecov', '~> 0.1.10'
  spec.add_development_dependency 'rubocop', '~> 0.62.0'

  # We want to have these in the production environment as well in case we need
  # to debug the application:
  spec.add_dependency 'awesome_print', '~> 1.8.0'
  spec.add_dependency 'config', '>= 1.5', '< 1.8'
  spec.add_dependency 'pry', '~> 0.11.1'
  spec.add_dependency 'pry-byebug', '>= 3.5', '< 3.7'
  spec.add_dependency 'pry-rescue', '~> 1.4.5'
  spec.add_dependency 'pry-stack_explorer', '~> 0.4.9.2'

  # Production dependencies
  # Sneakers depends on bunny and has the version requirement
  spec.add_dependency 'bunny'
  spec.add_dependency 'sneakers', '>= 2.6', '< 2.8'
end
