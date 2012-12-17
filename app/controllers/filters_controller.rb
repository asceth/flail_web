class FiltersController < ApplicationController
  inherit_resources

  def show
    @filter = Filter.find(params[:id])
    @filtered_exceptions = FlailException.digested(@filter.filtered_exceptions)
    show!
  end

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

  def edit
    @filter = Filter.find(params[:id])
    @filter_selector = FilterSelector.from_filter(@filter)
    edit!
  end

  def update
    filter_selector_params = params[:filter].delete(:filter_selector)
    filter_selector = FilterSelector.new(filter_selector_params)

    @filter = Filter.find(params[:id])
    params[:filter] = filter_selector.nullify_unselected_parameters(params[:filter])

    update! do |success, failure|
      success.html { redirect_to filter_url(@filter) }
      failure.html {
        @filter_selector = FilterSelector.from_filter(@filter)
        render action: "edit", status: 422
      }
    end
  end
end
