require 'test_helper'

class FlailExceptionTest < ActiveSupport::TestCase
  def exception_params
    {
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
  end

  DummyFilter = Struct.new(:return_value) do
    def match?(_)
      return_value
    end
  end

  test "should set the digest on create" do
    fe = FlailException.swing!(exception_params)
    my_digest = "ea07d5523f6f1c2fa2f17be5f5847e30"
    assert_equal fe.digest, my_digest,
                 "Digest should have been #{my_digest}, but was #{fe.digest}"
  end

  test "should mark itself resolved if it matches a filter" do
    fe = FlailException.swing!(:trace => [{}])
    fe_filter = DummyFilter.new(true)

    fe.check_against_filters!([fe_filter])
    assert fe.resolved?,
           "The exception should have been resolved but wasn't"
  end

  test "should not mark itself resolved if it fails to match any filter" do
    fe = FlailException.swing!(:trace => [{}])
    fe_filter = DummyFilter.new(false)

    fe.check_against_filters!([fe_filter])
    refute fe.resolved?,
           "The exception shouldn't have been resolved but was"
  end
end
