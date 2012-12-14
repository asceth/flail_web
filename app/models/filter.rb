class Filter < ActiveRecord::Base
  include RequestParameters::Conversion

  LIMITING_PARAMETERS = [:class_name, :message, :request_params, :user_agent]
  GENERAL_PARAMETERS = [:target_url, :environment, :hostname, :tag]
  ALL_PARAMETERS = LIMITING_PARAMETERS + GENERAL_PARAMETERS
  REGULAR_PARAMETERS = ALL_PARAMETERS - [:request_params]

  attr_accessible *ALL_PARAMETERS

  validate :has_at_least_one_limiting_parameter

  def request_params=(value)
    @request_params = RequestParameters(value)
    self.params_including = request_params.to_json

    @request_params
  end

  def request_params
    @request_params ||= RequestParameters.new(params_including)
  end

  def match?(flail_exception)
    matches_regular_parameters?(flail_exception) and
    matches_request_params?(flail_exception)
  end

  def parameters
    parameters_hash = HashWithIndifferentAccess.new

    ALL_PARAMETERS.each do |parameter|
      parameters_hash[parameter] = send(parameter)
    end

    parameters_hash
  end

  def parameters=(other_parameters)
    ALL_PARAMETERS.each do |parameter|
      value = other_parameters[parameter] || other_parameters[parameter.to_s]
      send("#{parameter}=", value)
    end

    parameters
  end

  def subset_with(filter_selector)
    filter = self.class.new(self.attributes.select {|k, v| ALL_PARAMETERS.include?(k.to_sym) })
    filter.request_params = request_params

    ALL_PARAMETERS.each do |parameter|
      filter.send("#{parameter}=", nil) unless filter_selector.send(parameter)
    end

    filter
  end

  def to_s
    parameters_hash.map {|k, v| "#{k}: #{v}" }.join("; ")
  end

  def has_at_least_one_limiting_parameter
    unless LIMITING_PARAMETERS.detect {|parameter| !self.send(parameter).blank? }
      filter_list = LIMITING_PARAMETERS.to_sentence(last_word_connector: " or ")
      errors.add(:base, "A filter must include at least one of #{filter_list}")
    end
  end

  module ClassMethods
    def new_from_exception(flail_exception)
      return new if flail_exception.nil?

      attributes = {}
      REGULAR_PARAMETERS.each do |key|
        value = flail_exception.send(key)
        attributes[key] = value unless value.blank?
      end
      attributes["request_params"] = flail_exception.params

      new(attributes)
    end
  end
  extend ClassMethods

  private

  def matches_regular_parameters?(flail_exception)
    regular_parameters = REGULAR_PARAMETERS.reject {|parameter| self[parameter].blank? }
    regular_parameters.all? {|parameter| flail_exception[parameter] == self[parameter] }
  end

  def matches_request_params?(flail_exception)
    request_params.match?(flail_exception.params)
  end

  def parameters_hash
    ALL_PARAMETERS.inject({}) { |hsh, parameter|
      value = self.send(parameter)
      hsh[parameter] = value unless value.blank?

      hsh
    }
  end
end
