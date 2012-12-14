require 'test_helper'

class FilterTest < ActiveSupport::TestCase

  DummyException = Struct.new(:class_name, :message, :environment, :hostname,
                              :tag, :target_url, :user_agent, :params)

  DummyFilterSelector = Struct.new(:class_name, :message, :environment, :hostname,
                                   :tag, :target_url, :user_agent, :request_params)

  test "should validate with just a class_name" do
    assert Filter.new(class_name: "LocalJumpError").valid?,
           "a Filter with just a class_name should be valid but isn't"
  end

  test "should validate with just a message" do
    assert Filter.new(message: "undefined method `provider' for nil:NilClass").valid?,
           "a Filter with just a message should be valid but isn't"
  end

  test "should validate with just a hash of parameters to include" do
    request_params = {controller: "things", action: "index"}
    assert Filter.new(request_params: request_params).valid?,
           "a Filter with just a hash of parameters to include should be valid but isn't"
  end

  test "should validate with request_params as a JSON object" do
    request_params = "{\"controller\":\"things\",\"action\":\"index\"}"
    assert Filter.new(request_params: request_params).valid?,
           "a Filter with request_params as a JSON object should be valid but isn't"
  end

  test "should validate with just a user_agent" do
    assert Filter.new(user_agent: "Mozilla/5.0 (Windows NT 6.1)").valid?,
           "a Filter with just a user_agent should be valid but isn't"
  end

  test "shouldn't validate without at least one limiting filter" do
    refute Filter.new(environment: "production").valid?,
           "a Filter with no limiting parameter shouldn't be valid but is"
  end

  test "shouldn't validate with just an empty request_params hash" do
    request_params = RequestParameters.new({})
    refute Filter.new(request_params: request_params).valid?,
           "a Filter with just an empty request_params shouldn't be valid but is"
  end

  test "should match an exception if all filtering parameters match" do
    filter = Filter.new
    filter.class_name = "Engineering::WarpDriveError"
    filter.message = "Antimatter containment failure; core breach imminent"
    filter.tag = "Voyager"

    fe = DummyException.new
    fe[:class_name] = filter.class_name
    fe[:message]    = filter.message
    fe[:tag]        = filter.tag

    assert filter.match?(fe),
           "Filter should have matched exception, but didn't"
  end

  test "should not require an exception to match nil filtering parameters" do
    filter = Filter.new
    filter.class_name = "LCARS::QueryError"
    filter.tag = "Voyager"

    fe = DummyException.new
    fe[:class_name] = filter.class_name
    fe[:tag]        = filter.tag
    fe[:user_agent] = "Borg/Neural interface"

    assert filter.match?(fe),
           "Filter should have matched exception, but didn't"
  end

  test "should not match an exception with a mismatched filtered parameter" do
    filter = Filter.new
    filter.class_name = "BorgCollective::IndividualityError"
    filter.hostname   = "unimatrix01"

    fe = DummyException.new
    fe[:class_name] = filter.class_name
    filter.hostname   = "unimatrix323"

    refute filter.match?(fe),
           "Filter shouldn't have matched exception, but did"
  end

  test "should coerce to a string by stringifying its parameters" do
    filter = Filter.new
    filter.tag = "Voyager"
    filter.request_params = RequestParameters.new('controller' => 'drones', 'id' => '7')

    assert filter.to_s =~ /tag: Voyager/,
           "Filter#to_s should've included its tag but didn't"
    assert filter.to_s =~ /request_params: {"controller":"drones","id":"7"}/,
           "Filter#to_s should've included request_params but didn't"
  end

  test "should not include nil parameters in string coercion" do
    filter = Filter.new
    refute filter.to_s =~ /tag:/,
           "Filter shouldn't have included its tag, but did"
    refute filter.to_s =~ /request_params:/,
           "Filter#to_s shouldn't have included request_params but did"
  end

  test "should generate a new filter from a flail exception" do
    fe = DummyException.new
    fe[:class_name] = "BorgCollective::AssimilationError"

    filter = Filter.new_from_exception(fe)
    assert_equal filter.class_name, fe.class_name
  end

  test "should enumerate its parameters, indifferently" do
    filter = Filter.new
    filter.class_name = "Security::AccessDeniedError"
    filter.message = "Level six security authorization is required"
    filter.tag = "Voyager"

    parameters = filter.parameters
    assert_equal filter.class_name, filter.parameters[:class_name]
    assert_equal filter.message,    filter.parameters['message']
    assert_equal filter.tag,        filter.parameters[:tag]
  end

  test "should allow indifferent assignment of its parameters" do
    filter = Filter.new
    parameters = {
      :class_name => "Medical::EmergencyMedicalHologramError",
      'message' => "The EMH could not be activated"
    }

    filter.parameters = parameters
    assert_equal parameters[:class_name], filter.class_name
    assert_equal parameters['message'],    filter.message
  end

  test "should make a new filter by subsetting with a filter_selector" do
    filter_selector = DummyFilterSelector.new
    filter_selector[:class_name] = true

    filter = Filter.new(class_name: "Engineering::PropulsionError",
                        message: "Starboard nacelle is venting plasma")
    new_filter = filter.subset_with(filter_selector)

    assert_equal filter.class_name, new_filter.class_name
    refute_nil filter.message
    assert_nil new_filter.message
  end

  test "should include request_params in the new filter, if selected" do
    filter_selector = DummyFilterSelector.new
    filter_selector[:request_params] = true

    filter = Filter.new(request_params: {controller: "things", action: "index"})
    new_filter = filter.subset_with(filter_selector)

    assert_equal filter.request_params, new_filter.request_params
  end
end
