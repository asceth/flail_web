require 'test_helper'

class FilterTest < ActiveSupport::TestCase

  DummyException = Struct.new(:class_name, :message, :environment, :hostname,
                              :tag, :target_url, :user_agent, :params)

  test "should validate with just a class_name" do
    assert Filter.new(class_name: "LocalJumpError").valid?,
           "a Filter with just a class_name should be valid but isn't"
  end

  test "should validate with just a message" do
    assert Filter.new(message: "undefined method `provider' for nil:NilClass").valid?,
           "a Filter with just a message should be valid but isn't"
  end

  test "should validate with just a hash of parameters to include" do
    request_params = RequestParameters.new('controller' => "things", 'action' => "index")
    assert Filter.new(request_params: request_params).valid?,
           "a Filter with just a hash of parameters to include should be valid but isn't"
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
end
