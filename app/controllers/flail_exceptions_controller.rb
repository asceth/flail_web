class FlailExceptionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]

  inherit_resources

  has_scope :tagged, :only => [:index]
  has_scope :unresolved, :type => :boolean, :default => true, :only => [:index]

  def index
    index! do |format|
      format.json do
        range = (0..23).to_a.map do |index|
          (23 - index).hours.ago
        end

        scope = FlailException.within(24.hours.ago)
        scope = scope.tagged(params[:tagged]) unless params[:tagged].blank?

        group = scope.group_by do |fe|
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
end
