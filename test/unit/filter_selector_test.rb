require 'test_helper'

class FilterSelectorTest < ActiveSupport::TestCase
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
end
