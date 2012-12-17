require 'test_helper'

class FiltersControllerTest < ActionController::TestCase
  def default_attrs
    { class_name: "NoMethodError" }
  end

  def new_filter_id(attrs = {})
    attrs = default_attrs.merge!(attrs)
    filter = Filter.create(attrs)

    filter.id
  end

  test "GET #show should render the :show template" do
    get :show, id: new_filter_id
    assert_template "show"
  end

  test "GET #show should assign @filtered_exceptions" do
    get :show, id: new_filter_id
    refute_nil assigns(:filtered_exceptions)
  end

  test "POST #create should create a flail exceptions filter" do
    assert_difference 'Filter.count' do
      post :create, filter: {
        class_name: "ArgumentError",
        filter_selector: { class_name: '1' }
      }
    end
  end

  test "POST #create should redirect to the filters index on success" do
    post :create, filter: {
      class_name: "ArgumentError",
      filter_selector: { class_name: '1' }
    }
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

  test "POST #create should retain the error information on failure" do
    post :create, filter: {}

    refute_empty assigns(:filter).errors
  end

  test "POST #create should retain the entered attributes on failure" do
    post :create, filter: {
      class_name: "ArgumentError",
      filter_selector: { class_name: '0' }
    }

    assert_equal "ArgumentError", assigns(:filter).class_name
  end
end
