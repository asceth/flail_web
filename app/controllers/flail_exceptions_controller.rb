class FlailExceptionsController < ApplicationController
  inherit_resources

  has_scope :tagged, :only => [:index]

  def index
    index! do |format|
      format.json do
        range = (0..23).to_a.map do |index|
          (23 - index).hours.ago
        end

        group = FlailException.within(24.hours.ago).group_by do |fe|
          fe.created_at.strftime('%j/%H')
        end

        data = (0..23).to_a.inject([]) do |arr, index|
          fes = group[range[index].strftime('%j/%H')] || []

          arr << {
            :index => index,
            :x => index,
            :y => fes.size,
            :label => {
              :x => range[index].strftime('%l%p'),
              :y => fes.size.to_s
            }
          }
        end

        render :json => data
      end
    end
  end

  def create
    FlailException.swing!(params)

    render :nothing => true
  end

  #
  # for now update simply resolves the set of digested exceptions
  #
  def update
    resource.resolve!

    respond_to do |format|
      format.js do
        render :nothing => true
      end

      format.html do
        flash[:notice] = "Resolved #{resource.occurences.count + 1} flailing exceptions: #{resource.class_name}"
        redirect_to root_url
      end
    end
  end
end
