class HistoryController < ApplicationController
  before_action :authenticate_user!

  def index
    year  = params[:year]&.to_i || Date.current.year
    month = params[:month]&.to_i || Date.current.month

    start_date = Date.new(year, month, 1)
    end_date   = start_date.end_of_month

    sleep_records = current_user.sleep_records.where(wake_time: start_date.beginning_of_day..end_date.end_of_day).order(:wake_time)
    finished_records = sleep_records.finished

    month_days = (start_date..end_date).to_a
    aggregator = SleepRecordAggregator.new(finished_records)
    @monthly_records = aggregator.build_cumulative(month_days, exclude_prev_record: true)

    @series = SleepRecordChartBuilder.new(sleep_records).build_series(range: start_date.beginning_of_day..end_date.end_of_day)

    averages = aggregator.average_daily_hours(@monthly_records, exclude_today: true)
    @month_average_wake_hours = averages[:wake]
    @month_average_sleep_hours = averages[:sleep]

    valid_wake_records = finished_records.select { |r| r.wake_time.present? && r.wake_time.to_date < Date.current }
    valid_sleep_records = finished_records.select { |r| r.wake_time.present? && r.bed_time.present? && r.wake_time.to_date < Date.current }

    @month_average_wake_time = SleepRecordAggregator.new(valid_wake_records).average_time(:wake_time)
    @month_average_bed_time = SleepRecordAggregator.new(valid_sleep_records).average_time(:bed_time)

    @selected_year  = year
    @selected_month = month
  end
end
