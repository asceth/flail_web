require 'json'

class RequestParameters
  attr_reader :parameters_hash

  def initialize(hash_or_json)
    hash_or_json ||= {}

    @parameters_hash =
      if hash_or_json.kind_of? Hash
        hash_or_json
      else
        JSON.parse(hash_or_json)
      end
  end

  def blank?
    @parameters_hash.empty?
  end

  def match?(other)
    other_parameters = RequestParameters(other)

    @parameters_hash.all? {|k, v| other_parameters.matches_key_and_value?(k, v) }
  end

  def to_s
    to_json
  end

  def to_hash
    @parameters_hash
  end

  def to_json
    @parameters_hash.to_json
  end

  def to_request_params
    self
  end

  protected

  def matches_key_and_value?(key, value)
    @parameters_hash[key] == value
  end

  module Conversion
    def RequestParameters(other)
      if other.respond_to?(:to_request_params)
        other.to_request_params
      else
        RequestParameters.new(other)
      end
    end
  end
  include Conversion
end
