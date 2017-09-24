module Selectize::Ajax::Core
  class Control
    attr_accessor :resource, :field, :options

    def initialize(resource, field, options = {})
      @options = Selectize::Ajax::Core::Settings.new(options).call
      @resource = resource
      @field = field
    end

    def resource_name
      return resource.to_s.underscore.to_sym unless resource_object?

      class_name = resource.class.name.split('::').last
      return :form if class_name == 'Form'
      class_name.chomp('Form').underscore.to_sym
    end

    def resource_id
      [resource_name, field].join('_')
    end

    def value
      if resource_object? && resource.respond_to?(field)
        resource.send(field)
      else
        options.value
      end
    end

    def label
      options.label || field.to_s.titleize
    end

    def edit_resource
      @edit_resource ||= options.edit_path&.gsub(%r{^/+}, '')&.split('/')&.first
    end

    def resource_object
      @model_object ||= if resource_object?
        resource
      else
        resource.to_s.classify.constantize rescue nil
      end
    end

    def field_required?
      return false unless options.required
      return false if resource_object.blank? || !resource_object.respond_to?(:_validators)
      validators = resource_object._validators[field].map(&:class) rescue []
      [
        validators.include?(ActiveModel::Validations::PresenceValidator),
        validators.include?(ActiveRecord::Validations::PresenceValidator)
      ].any?
    rescue
      false
    end

    def has_error?
      @has_error ||= resource_object&.errors&.include?(field)
    end

    def can_add?
      options.add_path.present? && options.add_modal.present?
    end

    def can_edit?
      options.edit_path.present? && options.edit_modal.present?
    end

    private

    def resource_object?
      !resource.is_a?(String) || !resource.is_a?(Symbol)
    end
  end
end
