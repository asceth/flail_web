require 'net/http'

class WebHook < ActiveRecord::Base
  EVENT_TYPES = ['exception', 'resolution']

  attr_accessible :secure, :url, :event

  validates :url, :presence => true
  validates :event, :presence => true

  module ClassMethods
    def trigger(event, exception, exception_url)
      payload = case event
                when :exception
                  trigger_exception(exception)
                when :resolution
                  trigger_resolution(exception)
                end.merge(:url => exception_url)

      WebHook.where(:event => event).map do |hook|
        url = URI.parse(hook.url)

        http = Net::HTTP.new(url.host, url.port)

        http.read_timeout = 2
        http.open_timeout = 1

        if hook.secure
          http.use_ssl      = true
          http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
        else
          http.use_ssl      = false
        end

        begin
          http.post(url.path, payload.to_json, {'Content-type' => 'application/json', 'Accept' => 'application/json'})
        rescue Exception => e
          Rails.logger.error e.inspect
          nil
        end
      end
    end

    def trigger_exception(exception)
      similar = FlailException.with_digest(exception.digest).count

      {
        :event => 'exception',
        :tag => exception.tag,
        :environment => exception.environment,
        :similar => similar,
        :exception => exception.class_name,
      }
    end

    def trigger_resolution(exception)
      similar = FlailException.with_digest(exception.digest).count

      {
        :event => 'resolution',
        :tag => exception.tag,
        :environment => exception.environment,
        :similar => similar,
        :exception => exception.class_name,
      }
    end
  end
  extend ClassMethods
end
