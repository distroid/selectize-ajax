Dir[File.expand_path("#{File.dirname(__FILE__)}/ajax/core/*.rb")].each do |resource|
  require resource
end
require 'selectize/ajax/version'
require 'selectize/ajax/view_helpers'

if defined?(Rails)
  require 'selectize/ajax/railtie'
  require 'selectize/ajax/engine'
end

module Selectize::Ajax
end
