require 'test_helper'

class FilterManagementTest < ActionDispatch::IntegrationTest
  test "The filter_selector should be used to subset a new filter" do
    post "/filters", {
      filter: {
        class_name: "NoMethodError",
        message: "undefined method",
        filter_selector: {class_name: '1'}
      },
    }

    filter = Filter.last
    assert_equal "NoMethodError", filter.class_name
    assert_nil filter.message
  end

  test "The filter_selector should be used to update an existing filter" do
    filter = Filter.create(class_name: "NoMethodError")

    put "/filters/#{filter.id}", {
      filter: {
        class_name: "ArgumentError",
        message: "wrong number of arguments(0 for 1)",
        filter_selector: {message: '1'}
      },
    }

    filter.reload
    assert_nil filter.class_name
    assert_equal "wrong number of arguments(0 for 1)", filter.message
  end
end
