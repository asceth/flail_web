class WebHooksController < ApplicationController
  inherit_resources

  def index
  end

  def create
    create! { web_hooks_url }
  end

  def test
    Rails.logger.info '--------------------------------------------'
    Rails.logger.info params.inspect
    Rails.logger.info '--------------------------------------------'

    render :nothing => true
  end
end
