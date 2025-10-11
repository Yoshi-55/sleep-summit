class HistoryController < ApplicationController
  before_action :authenticate_user!

  def index
    year  = params[:year]&.to_i || Date.current.year
    month = params[:month]&.to_i || Date.current.month

    start_date = Date.new(year, month, 1)
    end_date   = start_date.end_of_month

    sleep_records = current_user.sleep_records.where(
      wake_time: start_date.beginning_of_day..end_date.end_of_day
    ).order(:wake_time)
    finished_records = sleep_records.finished

    month_days = (start_date..end_date).to_a
    @monthly_records = SleepRecord.build_cumulative(finished_records, month_days)

    @series = SleepRecord.build_series(sleep_records, range: start_date.beginning_of_day..end_date.end_of_day)

    # 平均時間
    @month_average_wake_hours  = SleepRecord.average_wake_hours(finished_records)
    @month_average_sleep_hours = SleepRecord.average_sleep_hours(finished_records)

    # 平均時刻
    @month_average_wake_time = SleepRecord.average_time(finished_records.with_wake_time, :wake_time)
    @month_average_bed_time  = SleepRecord.average_time(finished_records, :bed_time)

    @selected_year  = year
    @selected_month = month
  end
end
