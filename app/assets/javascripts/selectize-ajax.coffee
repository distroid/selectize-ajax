window.clearSelectizeModal = (modal) ->
  modal.find('.modal-header').empty()
  modal.find('.modal-body').empty()
  modal.data 'bs.modal', null

window.SelectizeAjax = class SelectizeAjax
  default_options =
    resource_id: '',
    resource_name: '',
    collection: '{}',
    collection_path: null,
    search_param: 'q',
    add_modal: null,
    edit_modal: null,
    edit_resource_template: null,

  _self = () ->
    @

  constructor: (options = {}) ->
    _self.options = Object.assign(default_options, options)
    @initialize()

  initialize: () ->
    return unless _self.options.resource_id?

    @selectize_control()
    @control_buttons()

  selectize_control: () ->
    $("##{_self.options.resource_id}").selectize
      persist: false
      maxItems: 1
      valueField: 'value'
      labelField: 'label'
      sortField: 'label'
      searchField: 'label'
      options: _self.options.collection
      render: item: (item, escape) ->
        [
          '<div>',
          (if item.label then '<span>' + escape(item.label) + '</span>' else ''),
          '</div>'
        ].join(' ')

      load: (query, callback) ->
        return callback() if !query.length || !_self.options.collection_path?

        self = this
        $.ajax
          url: _self.options.collection_path
          type: 'GET'
          dataType: 'json'
          data: { "#{_self.options.search_param}": query }
          error: ->
            callback()
            return
          success: (res) ->
            self.clearOptions()
            callback res

  control_buttons: () ->
    if _self.options.add_modal?
      @ajax_add_complete_script()
      @clear_add_form_script()

    if _self.options.edit_modal?
      @ajax_edit_complete_script()
      @edit_button_script()

  ajax_add_complete_script: () ->
    $(_self.options.add_modal).on 'ajax:complete', (evt, data, status, errors) ->
      return console.error 'Somthing went wrong, form submit return empty response.' unless data?

      if data.status == 200 or data.status == 201
        if data.responseJSON == null
          $(_self.options.add_modal).find('.modal-content').html data.responseText
          $(_self.options.add_modal).trigger 'error'
        else
          $this = $(this)
          provider = JSON.parse(data.responseText)
          selectizer = $("##{_self.options.resource_id}")[0].selectize
          selectizer.addOption provider
          selectizer.addItem provider.value
          $(_self.options.add_modal).modal 'hide'
          $selector = $("form[data-target=\"#{_self.options.add_modal}\"")
          if $selector.length > 0
            $selector[0].reset()

  clear_add_form_script: () ->
    $(_self.options.add_modal).on 'hidden.bs.modal, show.bs.modal', ->
      $selector = $("form[data-target=\"#{_self.options.add_modal}\"")
      $selector[0].reset() if $selector.length > 0

      $('.error').each ->
        $(this).remove()

      $('.field_with_errors').each ->
        $(this).removeClass 'field_with_errors'

  ajax_edit_complete_script: () ->
    $(document).on 'hidden.bs.modal', _self.options.edit_modal, ->
      clearSelectizeModal $(this)

    $(document).on 'ajax:complete', _self.options.edit_modal, (e, data) ->
      if data.responseJSON == null
        $(_self.options.edit_modal).find('.modal-content').html data.responseText
        $(_self.options.edit_modal).trigger 'error'
      else
        data = data.responseJSON
        $(_self.options.edit_modal).modal 'hide'
        if data.value != null and data.label != null
          $('div[data-value=\'' + data.value + '\']').find('span').text data.label
          $('div.selected[data-value=\'' + data.value + '\']').text data.label

  edit_button_script: () ->
    $edit_link = $(".edit-#{_self.options.resource_name}")
    if !$("##{_self.options.resource_id}").val()
      $edit_link.hide()
      $("##{_self.options.resource_id}")
        .closest('.selectize-ajax-wrapper')
        .addClass('selectize-ajax-wrapper--empty')
    else
      $edit_link.attr(
        'href',
        _self.options.edit_resource_template.replace('{{id}}', $("##{_self.options.resource_id}").val())
      )

    $(document).on 'change', "##{_self.options.resource_id}", ->
      if !$(this).val()
        $("##{_self.options.resource_id}")
          .closest('.selectize-ajax-wrapper')
          .addClass('selectize-ajax-wrapper--empty')
        return $edit_link.hide()

      $edit_link.show()
      $edit_link.attr(
        'href',
        _self.options.edit_resource_template.replace('{{id}}', $("##{_self.options.resource_id}").val())
      )
      $("##{_self.options.resource_id}")
        .closest('.selectize-ajax-wrapper')
        .removeClass('selectize-ajax-wrapper--empty')
