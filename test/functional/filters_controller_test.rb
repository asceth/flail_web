require 'test_helper'

class FiltersControllerTest < ActionController::TestCase
  test "POST #create should create a flail exceptions filter" do
    assert_difference 'Filter.count' do
      post :create, filter: {class_name: "ArgumentError"}
    end
  end

  test "POST #create should redirect to the filters index on success" do
    post :create, filter: {class_name: "ArgumentError"}
    assert_redirected_to controller: "filters", action: "index"
  end

  test "POST #create should render the :new template on failure" do
    post :create, filter: {}
    assert_template "new"
  end

  test "POST #create should respond with 422 Unprocessable Entity on failure" do
    post :create, filter: {}
    assert_response 422
  end
end
