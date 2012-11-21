class FiltersController < ApplicationController
  inherit_resources

  def create
    create! do |success, failure|
      success.html { redirect_to filters_url }
      failure.html { render action: "new", status: 422 }
    end
  end
end
