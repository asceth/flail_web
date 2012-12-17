class FilterSelector
  extend ActiveModel::Naming

  attr_accessor *Filter::ALL_PARAMETERS

  DEFAULT_SELECTION = {
    class_name:  true,
    message:     true,
    tag:         true,
    environment: true
  }

  def initialize(attrs = nil)
    attrs ||= DEFAULT_SELECTION
    attrs.each do |name, value|
      value = false if [0, '0'].include?(value)
      send("#{name}=", value)
    end
  end

  def persisted?; false; end

  def to_model; self; end
  def to_key;    nil; end
  def to_param;  nil; end

  def nullify_unselected_parameters(parameters)
    updated_parameters = parameters.dup
    parameters.each do |name, _|
      updated_parameters[name] = nil unless send(name)
    end

    updated_parameters
  end

  module ClassMethods
    def from_filter(filter)
      attrs = {}
      filter.parameters.each do |name, value|
        attrs[name] = true unless value.blank?
      end

      new(attrs)
    end
  end
  extend ClassMethods
end
