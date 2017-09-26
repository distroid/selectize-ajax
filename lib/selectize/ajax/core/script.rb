module Selectize::Ajax::Core
  class Script
    attr_accessor :control

    def initialize(control)
      @control = control
    end

    def call
      js_script_tag
    end

    private

    def js_script_tag
      "<script type=\"text/javascript\">
        $(function(event) {
          setTimeout(function() {
            obj = new window.SelectizeAjax(#{tag_options.to_json});
            SJCollection['#{control.resource_id}'] = obj;
          });
        });
      </script>"
    end

    def tag_options
      options = {
        resource_id: control.resource_id,
        resource_name: control.resource_name
      }
      if control.options.collection.present?
        options[:collection] = control.options.collection
      end
      if control.options.collection_path.present?
        options[:search_param] = control.options.search_param.presence
        options[:collection_path] = control.options.collection_path
      end
      if control.can_edit?
        options[:edit_modal] = control.options.edit_modal
        options[:edit_resource_template] = control.edit_resource_template
      end
      options[:add_modal] = control.options.add_modal if control.can_add?
      options
    end
  end
end
