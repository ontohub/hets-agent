# frozen_string_literal: true

if RUBY_ENGINE == 'ruby' # not 'rbx'
  unless defined?(Coveralls)
    require 'simplecov'
    require 'coveralls'
    SimpleCov.formatters = [
      SimpleCov::Formatter::HTMLFormatter,
      Coveralls::SimpleCov::Formatter,
    ]
    SimpleCov.start
  end
end
