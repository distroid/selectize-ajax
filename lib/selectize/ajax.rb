require 'selectize/ajax/version'
require 'selectize/ajax/configuration'
require 'selectize/ajax/view_helpers'
require 'selectize/ajax/core/control'
require 'selectize/ajax/core/script'
require 'selectize/ajax/core/settings'

if defined?(Rails)
  require 'selectize/ajax/railtie'
  require 'selectize/ajax/engine'
end

module Selectize
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Ajax::Configuration.new
  end

  def self.reset
    @configuration = Ajax::Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
