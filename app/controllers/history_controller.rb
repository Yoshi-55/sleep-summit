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
    @monthly_records = SleepRecord.build_cumulative(finished_records, month_days)

    @series = SleepRecord.build_series(sleep_records, range: start_date.beginning_of_day..end_date.end_of_day)

    # 日ごと集計して平均を計算（累計 ÷ 記録のある日数）
    valid_days = @monthly_records.select { |d| d[:daily_sleep_hours].present? && d[:daily_wake_hours].present? }

    @month_average_sleep_hours = valid_days.any? ? (valid_days.sum { |d| d[:daily_sleep_hours] } / valid_days.size).round(2) : 0.0
    @month_average_wake_hours  = valid_days.any? ? (valid_days.sum { |d| d[:daily_wake_hours] } / valid_days.size).round(2) : 0.0

    valid_wake_records  = finished_records.select { |r| r.wake_time.present? }
    valid_sleep_records = finished_records.select { |r| r.wake_time.present? && r.bed_time.present? }

    @month_average_wake_time = SleepRecord.average_time(valid_wake_records, :wake_time)
    @month_average_bed_time  = SleepRecord.average_time(valid_sleep_records, :bed_time)

    @selected_year  = year
    @selected_month = month
  end
end
