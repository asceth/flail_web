require 'test_helper'

class ExceptionFilteringTest < ActionDispatch::IntegrationTest
  def exception_params
    {
      class_name: "ActionController::RoutingError",
      message: 'No route matches "/crossdomain.xml" with {:method => :get}',
      environment: "production",
      tag: "Voyager",
      target_url: "http://voyager.starfleet.lcars/crossdomain.xml",
      user_agent: "Mozilla/5.0",
      hostname: Socket.gethostname.to_s,
      trace: [
        {
          file: "[GEM_ROOT]/gems/actionpack-3.0.7/lib/action_dispatch/middleware/show_exceptions.rb",
          number: "53",
          method: "call"
        },
        {
          file: "[GEM_ROOT]/gems/railties-3.0.7/lib/rails/rack/logger.rb",
          number: "13",
          method: "call"
        },
        {
          file: "[GEM_ROOT]/gems/rack-1.2.5/lib/rack/runtime.rb",
          number: "17",
          method: "call"
        }
      ]
    }
  end

  test "A new exception swung with no filter should be unresolved" do
    assert_difference 'FlailException.unresolved.count' do
      post "/swing", exception_params
      assert_response :success
    end
  end

  test "A new exception swung with a matching filter should be resolved" do
    get "/filters/new"
    assert_response :success

    assert_difference 'Filter.count' do
      filtering_params = exception_params.reject {|k, v| ![:class_name, :message].include?(k) }
      post "/filters", {filter: filtering_params}
    end

    assert_no_difference 'FlailException.unresolved.count' do
      post "/swing", exception_params
      assert_response :success
    end
  end

  test "A new exception swung with a non-matching filter should be unresolved" do
    filtering_params = {class_name: "NoMethodError"}
    post "/filters", {filter: filtering_params}

    assert_difference 'FlailException.unresolved.count' do
      post "/swing", exception_params
      assert_response :success
    end
  end
end
