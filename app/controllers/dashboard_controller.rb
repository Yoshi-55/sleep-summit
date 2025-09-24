class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    sleep_records = current_user.sleep_records.order(:bed_time)
    @unwoken_record = current_user.sleep_records.unwoken.first

    @series = SleepRecord.build_series(sleep_records, days: 7)

    @weekly_records = SleepRecord.build_weekly_cumulative(sleep_records, days: 7)

    finished_records = sleep_records.select(&:wake_time)
    @today_sleep = finished_records.find { |r| r.bed_time >= Time.current.beginning_of_day && r.wake_time <= Time.current.end_of_day }
    @total_sleep_hours = SleepRecord.total_sleep_hours(finished_records)
    @average_sleep_hours = finished_records.any? ? (@total_sleep_hours / finished_records.size).round(2) : 0
  end
end