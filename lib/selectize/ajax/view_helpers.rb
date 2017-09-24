module Selectize::Ajax
  module ViewHelpers
    def selectize_ajax_tag(resource, field, options = {})
      control = Selectize::Ajax::Core::Control.new(resource, field, options)
      script = Selectize::Ajax::Core::Script.new(control).call
      render 'selectize_ajax/tag', control: control, script: script
    end
  end
end
