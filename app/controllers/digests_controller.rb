class DigestsController < ApplicationController

  def show
    params[:offset] ||= 0
    resource
  end

  #
  # for now update simply resolves the set of digested exceptions
  #
  def update
    resource.resolve!

    respond_to do |format|
      format.js do
        render :js => "$('#digest_#{resource.digest}').fadeOut(500, function () { $(this).remove(); });"
      end

      format.html do
        flash[:notice] = "Resolved #{resource.occurrences.count} flailing exceptions: #{resource.class_name}"
        redirect_to root_url
      end
    end
  end

  def resource
    @resource ||= FlailException.with_digest(params[:id]).order('created_at desc').offset(params[:offset].to_i).first
  end
  helper_method :resource
end
