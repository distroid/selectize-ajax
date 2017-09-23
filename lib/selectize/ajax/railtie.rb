require 'rails/railtie'

module Selectize
  module Ajax
    class Railtie < ::Rails::Railtie
      initializer 'selectize_ajax.view_helpers' do
        ActionView::Base.send :include, Selectize::Ajax::ViewHelpers
      end
    end
  end
end
