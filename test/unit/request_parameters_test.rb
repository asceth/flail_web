require 'test_helper'

class RequestParametersTest < ActiveSupport::TestCase
  def subject
    RequestParameters.new('controller' => 'widgets', 'id' => '2')
  end

  test "should initialize with nil, to no parameters" do
    request_params = RequestParameters.new(nil)
    assert_empty request_params.parameters_hash
  end

  test "should initialize with a hash" do
    request_params = RequestParameters.new('controller' => 'widgets', 'id' => '2')
    assert_equal request_params.parameters_hash, {'controller' => 'widgets', 'id' => '2'}
  end

  test "should initialize with a JSON object" do
    request_params = RequestParameters.new('{"controller":"widgets", "id":"2"}')
    assert_equal request_params.parameters_hash, {'controller' => 'widgets', 'id' => '2'}
  end

  test "should match against a matching instance of RequestParameters" do
    test_params = RequestParameters.new('controller' => 'widgets', 'id' => '2', 'action' => 'show')
    assert subject.match?(test_params),
           "#{subject} should have matched #{test_params.inspect} but didn't"
  end

  test "should match against a matching hash" do
    test_params = {'controller' => 'widgets', 'id' => '2', 'action' => 'show'}
    assert subject.match?(test_params),
           "#{subject} should have matched #{test_params.inspect} but didn't"
  end

  test "should match against a matching JSON object" do
    test_params = '{"controller":"widgets", "id":"2", "action":"show"}'
    assert subject.match?(test_params),
           "#{subject} should have matched #{test_params.inspect} but didn't"
  end

  test "should match against nil when appropriate" do
    request_params = RequestParameters.new({})
    assert request_params.match?(nil),
           "#{request_params} should have matched nil but didn't"
  end

  test "should not match against a mismatched instance of RequestParameters" do
    test_params = RequestParameters.new('controller' => 'widgets', 'id' => '7', 'action' => 'show')
    refute subject.match?(test_params),
           "#{subject} shouldn't have matched #{test_params.inspect} but did"
  end

  test "should not match against a mismatched hash" do
    test_params = {'controller' => 'widgets', 'id' => '5', 'action' => 'show'}
    refute subject.match?(test_params),
           "#{subject} shouldn't have matched #{test_params.inspect} but did"
  end

  test "should not match against a mismatched JSON object" do
    test_params = '{"controller":"widgets", "id":"3", "action":"show"}'
    refute subject.match?(test_params),
           "#{subject} shouldn't have matched #{test_params.inspect} but did"
  end
end
