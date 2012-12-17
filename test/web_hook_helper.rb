module WebHookHelper
  TEST_WEB_HOOK_HOST = "http://localhost:3535"

  @@warning_given = false
  @@alive = nil

  def send_request(path, options = {})
    uri = URI("#{TEST_WEB_HOOK_HOST}/#{path}")
    method = options.delete(:method) || 'get'

    case method.to_s
    when 'get'
      uri.query = URI.encode_www_form(options)
      Net::HTTP.get_response(uri).body
    when 'post'
      Net::HTTP.post_form(uri, options).body
    end
  end

  def alive?
    return @@alive unless @@alive.nil?

    send_request("result")
    @@alive = true
  rescue Errno::ECONNREFUSED
    give_warning
    @@alive = false
  end

  def give_warning
    unless @@warning_given
      $stderr.puts "The server to test web hooks is down. Start it up with:"
      $stderr.puts
      $stderr.puts "  rackup test/web_hook_receiver.ru -p 3535"
      $stderr.puts
      @@warning_given = true
    end
  end

  def clear
    send_request("reset", :method => 'post')
  end

  def result(number = -1)
    JSON.parse(send_request("result", :number => number))
  end

  def set_hook(hook_type)
    post "/web_hooks", {web_hook: {url: "#{TEST_WEB_HOOK_HOST}/receiver", event: hook_type}}
  end
end
