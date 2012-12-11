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
end
