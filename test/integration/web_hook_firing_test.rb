require 'test_helper'
require 'web_hook_helper'

class WebHookFiringTest < ActionDispatch::IntegrationTest
  include WebHookHelper

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

  def setup
    if alive?
      clear
    else
      skip("web hook test server is down")
    end
  end

  test "A new exception should trigger an exception hook" do
    set_hook('exception')

    post "/swing", exception_params
    assert_response :success

    hook_result = result['payload']
    assert_equal "exception", hook_result['event']
    assert_equal "ActionController::RoutingError", hook_result['exception']
    assert_equal "Voyager", hook_result['tag']
    assert_equal "production", hook_result['environment']
  end

  test "A resolved exception should trigger a resolution hook" do
    set_hook('resolution')

    post "/swing", exception_params
    assert_response :success

    assert_empty result

    digest = FlailException.last.digest
    put "/digests/#{digest}"

    hook_result = result['payload']
    assert_equal "resolution", hook_result['event']
    assert_equal "ActionController::RoutingError", hook_result['exception']
    assert_equal "Voyager", hook_result['tag']
    assert_equal "production", hook_result['environment']
  end

  test "A new exception that gets filtered shouldn't trigger an exception hook" do
    set_hook('exception')

    filtering_params = exception_params.reject {|k, v| ![:class_name, :message].include?(k) }
    post "/filters", {filter: filtering_params}

    post "/swing", exception_params
    assert_response :success

    assert_empty result
  end
end
