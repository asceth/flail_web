require 'rubygems'
require 'json'

module Rack
  class MethodNotAllowed < StandardError; end

  class TestWebHookReceiver
    def initialize
      clear
    end

    def call(env)
      request = Rack::Request.new(env)
      path = request.path_info
      body = request.body.read

      if path == "/receiver"
        check_method(request, :post?)
        store_payload(body)
      elsif path == "/result"
        check_method(request, :get?)
        number = request.params['number'] || -1
        fetch_payload(number.to_i)
      elsif path == "/reset"
        check_method(request, :post?)
        clear
        return_success("cleared")
      else
        return_not_found(path)
      end
    rescue MethodNotAllowed
      return_method_not_allowed
    rescue => e
      return_server_error(e.message)
    end

    def fetch_payload(number)
      payload = @received_payloads[number] || "{}"
      return_success(payload)
    end

    def store_payload(payload)
      @received_payloads << payload
      return_success(payload)
    end

    def clear
      @received_payloads = []
    end

    def check_method(request, method)
      raise MethodNotAllowed unless request.send(method)
    end

    def return_success(payload)
      [200, {'Content-Type' => 'application/json'}, [payload]]
    end

    def return_not_found(path)
      [405, {'Content-Type' => 'application/json'}, ["unknown route #{path}"]]
    end

    def return_method_not_allowed
      [405, {'Content-Type' => 'application/json'}, ["Method Not Allowed"]]
    end

    def return_server_error(message)
      [500, {'Content-Type' => 'application/json'}, [message]]
    end
  end
end

service = Rack::TestWebHookReceiver.new
run service
