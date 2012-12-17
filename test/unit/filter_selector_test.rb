require 'test_helper'

class FilterSelectorTest < ActiveSupport::TestCase
  DummyFilter = Struct.new(:class_name, :message, :environment, :hostname,
                           :tag, :target_url, :user_agent, :request_params) do
    def parameters
      [:class_name, :message, :environment, :hostname,
       :tag, :target_url, :user_agent, :request_params].inject({}) { |hsh, key|
        hsh[key] = send(key)
        hsh
      }
    end
  end

  test "should initialize from a hash of attributes" do
    filter_selector = FilterSelector.new(class_name: true)

    assert filter_selector.class_name,
           "class_name should've been true, but wasn't"
    refute filter_selector.message,
           "message should've been false, but wasn't"
  end

  test "should initialize to false with a value of 0 or '0' " do
    filter_selector = FilterSelector.new(class_name: 0, message: '0')

    refute filter_selector.class_name,
           "class_name should've been false, but wasn't"
    refute filter_selector.message,
           "message should've been false, but wasn't"
  end

  test "should default to something sensible" do
    filter_selector = FilterSelector.new

    assert filter_selector.class_name,
           "class_name should've been true, but wasn't"
    assert filter_selector.message,
           "message should've been true, but wasn't"
    assert filter_selector.tag,
           "tag should've been true, but wasn't"
    assert filter_selector.environment,
           "environment should've been true, but wasn't"
  end

  test "should create a FilterSelector from a Filter" do
    filter = DummyFilter.new
    filter.request_params = '{"controller":"doodads","action":"update"}'
    filter.hostname = "deep.thought"

    filter_selector = FilterSelector.from_filter(filter)

    refute filter_selector.class_name,
           "class_name should've been false, but wasn't"
    refute filter_selector.message,
           "message should've been false, but wasn't"
    assert filter_selector.request_params,
           "request_params should've been true, but wasn't"
    assert filter_selector.hostname,
           "hostname should've been true, but wasn't"
  end

  test "should nullify unselected parameters from a hash of parameters" do
    filter_selector = FilterSelector.new(class_name: true, request_params: true)
    parameters = {
      class_name: "NoMethodError",
      message: "undefined method",
      request_params: '{"controller":"doodads","action":"update"}'
    }

    updated_parameters = filter_selector.nullify_unselected_parameters(parameters)
    assert_equal parameters[:class_name], updated_parameters[:class_name]
    assert_equal parameters[:request_params], updated_parameters[:request_params]
    assert_nil updated_parameters[:message]
  end
end
