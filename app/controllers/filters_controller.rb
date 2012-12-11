class FiltersController < ApplicationController
  inherit_resources

  def new
    fe = FlailException.find_by_digest(params[:digest])
    @filter = Filter.new_from_exception(fe)
    @filter_selector = FilterSelector.new
    new!
  end

  def create
    filter_selector_params = params[:filter].delete(:filter_selector)
    @filter_selector = FilterSelector.new(filter_selector_params)

    original_filter = Filter.new(params[:filter])
    @filter = original_filter.subset_with(@filter_selector)

    create! do |success, failure|
      success.html { redirect_to filters_url }
      failure.html {
        @filter.parameters = original_filter.parameters
        render action: "new", status: 422
      }
    end
  end
end
