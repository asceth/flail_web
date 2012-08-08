namespace :flail do

  desc "Add a demo app & errors to your database (for testing)"
  task :demo => :environment do
    # Report a number of errors for the application
    FlailException.delete_all

    errors = [{
      :class_name => "ArgumentError",
      :message => "wrong number of arguments (3 for 0)"
    }, {
      :class_name => "RuntimeError",
      :message => "Could not find Red October"
    }, {
      :class_name => "TypeError",
      :message => "can't convert Symbol into Integer"
    }, {
      :class_name => "ActiveRecord::RecordNotFound",
      :message => "could not find a record with the id 5"
    }, {
      :class_name => "NameError",
      :message => "uninitialized constant Tag"
    }, {
      :class_name => "SyntaxError",
      :message => "unexpected tSTRING_BEG, expecting keyword_do or '{' or '('"
    }]

    RANDOM_METHODS = ActiveSupport.methods.shuffle[1..8]

    RANDOM_TAGS = ["flail", "github", "enterprise", "voyager"]

    def random_backtrace
      backtrace = []
      99.times do |t|
        file = "/path/to/file.rb"
        line = t.hash % 1000
        desc = RANDOM_METHODS.shuffle.first.to_s
        backtrace << "#{file}:#{line}:#{desc}"
      end
      backtrace
    end

    errors.each do |error_template|
      rand(34).times do

        error_report = error_template.reverse_merge({
                                                      :target_url => "http://www.example.com/bad",
                                                      :referer_url => "http://www.example.com/choice",
                                                      :user_agent => "Google/Chrome",
                                                      :environment => "production",
                                                      :hostname => "localhost",
                                                      :tag => RANDOM_TAGS.shuffle.first.to_s,
                                                      :class_name => "StandardError",
                                                      :message => "Oops. Something went wrong!",
                                                      :params => {
                                                        'controller' => 'main',
                                                        'action' => 'error'
                                                      }.to_json,
                                                      :user => {
                                                        :id => "1234",
                                                        :name => "jsmith"
                                                      }.to_json,
                                                      :trace => random_backtrace.to_json,
                                                    })

        fe = FlailException.swing!(error_report)
        fe.update_attribute(:created_at, rand(1.day).ago)
      end
    end

    puts "=== Created demo with example errors."
  end

end
