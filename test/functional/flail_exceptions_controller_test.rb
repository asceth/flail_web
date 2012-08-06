require 'test_helper'

class FlailExceptionsControllerTest < ActionController::TestCase
  test "should create an exception" do
    post(:create, {:class_name => "Test Exception",
           :message => "Testing exception generation",
           :trace => ["(irb):4:in `irb_binding'", "/Users/jlong/.rvm/rubies/ruby-1.8.7-p358/lib/ruby/1.8/irb/workspace.rb:52:in `irb_binding'", "/Users/jlong/.rvm/rubies/ruby-1.8.7-p358/lib/ruby/1.8/irb/workspace.rb:52"].to_json,
           :target_url => "http://badapp.com/lol",
           :referer_url => "http://badapp.com",
           :parameters => {:id => 1, :anchor => "flail"}.to_json,
           :user_agent => "Google/Chrome",
           :user => {}.to_json,
           :environment => "test",
           :hostname => Socket.gethostname.to_s,
           :tag => "test-me-amadeus",
         })

    assert_response :success
  end
end
