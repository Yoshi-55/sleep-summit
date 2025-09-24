class HistoryController < ApplicationController
  before_action :authenticate_user!

  def index
    sleep_records = current_user.sleep_records.order(:bed_time)

    @records = SleepRecord.build_weekly_cumulative(sleep_records, days: 30)

    @records.reverse!
  end
end