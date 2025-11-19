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

    # 日ごと集計して平均を計算（累計 ÷ 記録のある日数）
    valid_wake_days = @monthly_records.select { |d| d[:day].is_a?(Date) && d[:day] < Date.current && d[:daily_wake_hours].present? }
    valid_sleep_days = @monthly_records.select { |d| d[:day].is_a?(Date) && d[:day] < Date.current && d[:daily_sleep_hours].present? }

    @month_average_wake_hours = valid_wake_days.any? ? (valid_wake_days.sum { |d| d[:daily_wake_hours] } / valid_wake_days.size).round(2) : 0.0
    @month_average_sleep_hours = valid_sleep_days.any? ? (valid_sleep_days.sum { |d| d[:daily_sleep_hours] } / valid_sleep_days.size).round(2) : 0.0

    valid_wake_records  = finished_records.select { |r| r.wake_time.present? }
    valid_sleep_records = finished_records.select { |r| r.wake_time.present? && r.bed_time.present? }

    @month_average_wake_time = SleepRecordAggregator.new(valid_wake_records).average_time(:wake_time)
    @month_average_bed_time  = SleepRecordAggregator.new(valid_sleep_records).average_time(:bed_time)

    @selected_year  = year
    @selected_month = month
  end
end
