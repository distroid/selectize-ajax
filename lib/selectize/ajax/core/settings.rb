module Selectize::Ajax::Core
  class Settings
    def initialize(options = {})
      @options = options
    end

    def call
      ::OpenStruct.new(default_options.merge(@options))
    end

    private

    def default_options
      {
        collection: [],
        add_modal: nil,
        add_path: nil,
        add_button_text: I18n.t('selectize_ajax.add_button_text'),
        edit_path: nil,
        edit_modal: nil,
        edit_button_text: I18n.t('selectize_ajax.edit_button_text'),
        horizontal: true,
        label: nil,
        value: nil
      }
    end
  end
end
