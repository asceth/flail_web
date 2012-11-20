require 'test_helper'

class FlailExceptionTest < ActiveSupport::TestCase
  test "should set the digest on create" do
    params = {
      :class_name => "NoMethodError",
      :target_url => "https://mysterymachine.com/gggghosts",
      :environment => "production",
      :parameters => {
        'controller' => "gggghosts",
        'action' => "index"
      },
      :tag => "mystery-machine",
      :trace => [{:file => "app/models/gggghost.rb", :number => 22}]
    }

    fe = FlailException.swing!(params)

    assert_equal fe.digest, "ea07d5523f6f1c2fa2f17be5f5847e30"
  end
end
