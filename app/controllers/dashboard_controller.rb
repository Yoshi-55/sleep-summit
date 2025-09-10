class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @sleep_records = current_user.sleep_records.order(bed_time: :desc)
  end
end
