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
            #{selectize_script}
            #{ajax_add_complete_script}
            #{edit_button_script}
            #{ajax_edit_complete_script}
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
        #{selectize_remote_load_function}
        render: {
          item: function(item, escape) {
            return '<div>' +
                (item.label ? '<span>' + escape(item.label) + '</span>' : '') +
              '</div>';
          }
        }
      });"
    end

    def selectize_remote_load_function
      return if control.options.collection_path.blank?

      "load: function(query, callback) {
        if (!query.length) return callback();
        var self = this;
        $.ajax({
          url: '#{control.options.collection_path}',
          type: 'GET',
          dataType: 'json',
          data: {
            #{control.options.search_param}: query
          },
          error: function() { callback(); },
          success: function(res) {
            self.clearOptions();
            callback(res);
          }
        });
      },"
    end

    def ajax_add_complete_script
      return unless control.can_add?

      "$('#{control.options.add_modal}').on('ajax:complete', function(evt, data, status, errors) {
        if (typeof data == 'undefined') {
          console.error('Somthing went wrong, form submit return empty response.');
          return;
        }
        if (data.status == 200 || data.status == 201) {
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
            $selector = $('form[data-target=\"#{control.options.add_modal}\"');
            if ($selector.length > 0) {
              $selector[0].reset();
            }
          }
        }
      });"
    end

    def ajax_edit_complete_script
      return unless control.can_edit?

      "$(document).on('hidden.bs.modal', '#{control.options.edit_modal}', function() {
        return clearSelectizeModal($(this));
      });
      $(document).on('ajax:complete', '#{control.options.edit_modal}', function(e, data) {
        if (data.responseJSON == null) {
            $('#{control.options.edit_modal}').find('.modal-content').html(data.responseText);
            $('#{control.options.edit_modal}').trigger('error');
        } else {
          data = data.responseJSON;
          $('#{control.options.edit_modal}').modal('hide');
          if (data.value != null && data.label != null) {
            $(\"div[data-value='\" + data.value + \"']\").find('span').text(data.label);
            $(\"div.selected[data-value='\" + data.value + \"']\").text(data.label);
          }
        }
      });"
    end

    def edit_button_script
      return unless control.can_edit?

      "var $edit_link = $('.edit-#{control.resource_name}');
      if (!$('##{control.resource_id}').val()) {
        $edit_link.hide();
        $('##{control.resource_id}')
          .closest('.selectize-ajax-wrapper')
          .addClass('selectize-ajax-wrapper--empty');
      } else {
        $edit_link.attr(
          'href',
          '#{control.edit_resource_template}'.replace(
            '{{id}}',
            $('##{control.resource_id}').val()
          )
        );
      }
      $(document).on('change', '##{control.resource_id}', function() {
        if (!$(this).val()) {
          $('##{control.resource_id}')
            .closest('.selectize-ajax-wrapper')
            .addClass('selectize-ajax-wrapper--empty');
          return $edit_link.hide();
        }
        $edit_link.show();
        $edit_link.attr('href', '#{control.edit_resource_template}'.replace('{{id}}', $(this).val()));
        return $('##{control.resource_id}')
          .closest('.selectize-ajax-wrapper')
          .removeClass('selectize-ajax-wrapper--empty');
      });"
    end

    def clear_form_script
      "$('#{control.options.add_modal}').on('hidden.bs.modal, show.bs.modal', function () {
        $selector = $('form[data-target=\"#{control.options.add_modal}\"');
        if ($selector.length > 0) {
          $selector[0].reset();
        }
        $('.error').each(function () { $(this).remove(); });
        $('.field_with_errors').each(function () { $(this).removeClass('field_with_errors'); });
      });
      window.clearSelectizeModal = function(modal) {
        modal.find('.modal-header').empty();
        modal.find('.modal-body').empty();
        return modal.data('bs.modal', null);
      };
      "
    end
  end
end
