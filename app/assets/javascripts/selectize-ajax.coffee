window.clearSelectizeModal = (modal) ->
  modal.find('.modal-header').empty()
  modal.find('.modal-body').empty()
  modal.data 'bs.modal', null

window.SJCollection = {}

window.SelectizeAjax = class SelectizeAjax
  constructor: (options = {}) ->
    @options = options
    @initialize()

  initialize: () ->
    return unless @options.resource_id?

    @selectize_control()
    @control_buttons()

  selectize_control: () ->
    $("##{@options.resource_id}").selectize
      persist: false
      maxItems: 1
      valueField: 'value'
      labelField: 'label'
      sortField: 'label'
      searchField: 'label'
      options: @options.collection
      render: item: (item, escape) ->
        [
          '<div>',
          (if item.label then '<span>' + escape(item.label) + '</span>' else ''),
          '</div>'
        ].join(' ')

      load: (query, callback) ->
        options = SJCollection[this.$input.attr('id')].options
        return callback() if !query.length || !options.collection_path?

        self = this
        $.ajax
          url: options.collection_path
          type: 'GET'
          dataType: 'json'
          data: { "#{options.search_param}": query }
          error: ->
            callback()
          success: (res) ->
            self.clearOptions()
            callback res

  control_buttons: () ->
    if typeof @options.add_modal != 'undefined'
      @ajax_add_complete_script()
      @clear_add_form_script()

    if typeof @options.edit_modal != 'undefined'
      @ajax_edit_complete_script()
      @edit_button_script()

  ajax_add_complete_script: () ->
    $(@options.add_modal).data('resource_id', @options.resource_id)
    $(@options.add_modal).on 'ajax:complete', (evt, data, status, errors) ->
      return console.error 'Somthing went wrong, form submit return empty response.' unless data?
      return if data.status != 200 && data.status != 201

      if data.responseJSON == null || typeof data.responseJSON == 'undefined'
        $(this).find('.modal-content').html data.responseText
        $(this).trigger 'error'
      else
        provider = JSON.parse(data.responseText)
        resource_id = $(this).data('resource_id')

        if $("##{resource_id}").length > 0
          selectizer = $("##{resource_id}")[0].selectize
          selectizer.addOption provider
          selectizer.addItem provider.value

        $(this).modal('hide')
        $(this).find('form')[0].reset() if $(this).find('form').length > 0


  clear_add_form_script: () ->
    $(@options.add_modal).on 'hidden.bs.modal, show.bs.modal', ->
      $(this).find('form')[0].reset() if $(this).find('form').length > 0

      $('.error').each ->
        $(this).remove()

      $('.field_with_errors').each ->
        $(this).removeClass 'field_with_errors'

  ajax_edit_complete_script: () ->
    $(@options.edit_modal).data('resource_id', @options.resource_id)
    $(document).on 'hidden.bs.modal', @options.edit_modal, ->
      clearSelectizeModal $(this)

    $(document).on 'ajax:complete', @options.edit_modal, (e, data) ->
      if data.responseJSON == null || typeof data.responseJSON == 'undefined'
        $(this).find('.modal-content').html data.responseText
        $(this).trigger 'error'
      else
        data = data.responseJSON
        $(this).modal 'hide'
        if data.value != null and data.label != null
          $('div[data-value=\'' + data.value + '\']').find('span').text data.label
          $('div.selected[data-value=\'' + data.value + '\']').text data.label

  edit_button_script: () ->
    if !$("##{@options.resource_id}").val()
      $(".edit-#{@options.resource_id}").hide()
      $("##{@options.resource_id}")
        .closest('.selectize-ajax-wrapper')
        .addClass('selectize-ajax-wrapper--empty')
    else
      $(".edit-#{@options.resource_id}").attr(
        'href',
        @options.edit_resource_template.replace('{{id}}', $("##{@options.resource_id}").val())
      )

    $(document).on 'change', "##{@options.resource_id}", ->
      resource_id = $(this).attr('id')
      if !$(this).val()
        $(this).closest('.selectize-ajax-wrapper').addClass('selectize-ajax-wrapper--empty')
        return $(".edit-#{resource_id}").hide()

      options = SJCollection[resource_id].options
      $(".edit-#{resource_id}").show()
      $(".edit-#{resource_id}").attr(
        'href',
        options.edit_resource_template.replace('{{id}}', $(this).val())
      )
      $(this).closest('.selectize-ajax-wrapper').removeClass('selectize-ajax-wrapper--empty')
