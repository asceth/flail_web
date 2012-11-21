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

  def to_s
    parameters_hash.map {|k, v| "#{k}: #{v}" }.join("; ")
  end

  def has_at_least_one_limiting_parameter
    unless LIMITING_PARAMETERS.detect {|parameter| !self.send(parameter).blank? }
      filter_list = LIMITING_PARAMETERS.to_sentence(last_word_connector: " or ")
      errors.add(:base, "A filter must include at least one of #{filter_list}")
    end
  end

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
