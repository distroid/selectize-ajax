module Selectize::Ajax::Core
  class Script
    attr_accessor :control, :type

    def initialize(control, type)
      @control = control
      @type = type
    end

    def call
      return if [:tag].exclude?(type)
      send("js_script_#{type}")
    end

    private

    def js_script_tag
      "<script type=\"text/javascript\">
        $(function(event) {
          setTimeout(function() {
            #{selectize_script}
            #{ajax_complete_script}
            #{clear_form_script}
          });
        });
      </script>"
    end

    def selectize_script
      "var $select_#{control.resource_id} = $('##{control.resource_id}').selectize({
        persist: false,
        maxItems: 1,
        valueField: 'value',
        labelField: 'label',
        sortField: 'label',
        searchField: 'label',
        options: #{control.options.collection.to_json},
        onItemAdd: function(value, item) {
          item = $(item[0])
          item_text = item.find('span').text()
          $('##{control.resource_name}_title').val(item_text)
        },
        render: {
          item: function(item, escape) {
            return '<div>' +
                (item.label ? '<span>' + escape(item.label) + '</span>' : '') +
              '</div>';
          }
        }
      });"
    end

    def ajax_complete_script
      "$('#{control.options.add_modal}').on('ajax:complete', function(evt, data, status, errors) {
        if(data.status == 200 || data.status == 201) {
          if (data.responseJSON == null) {
            $('#{control.options.add_modal}').find('.modal-content').html(data.responseText);
            $('#{control.options.add_modal}').trigger('error');
          } else {
            var $this = $(this);
            var provider = JSON.parse(data.responseText)
            var selectizer =  $('##{control.resource_id}')[0].selectize;
            selectizer.addOption(provider);
            selectizer.addItem(provider.value);
            $('#{control.options.add_modal}').modal('hide');
            $('*[data-target=\"#{control.options.add_modal}\"')[1].reset();
          }
        }
      });"
    end

    def clear_form_script
      "$('#{control.options.add_modal}').on('hidden.bs.modal', function () {
        $('*[data-target=\"#{control.options.add_modal}\"')[1].reset();
        $('.error').each(function () { $(this).remove(); });
        $('.field_with_errors').each(function () { $(this).removeClass('field_with_errors'); });
      })"
    end
  end
end
