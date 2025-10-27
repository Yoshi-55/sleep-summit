class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    week_start = Date.current.beginning_of_week(:sunday).beginning_of_day
    week_end   = Date.current.end_of_week(:sunday).end_of_day

    @week_records = current_user.sleep_records.finished.where(wake_time: week_start..week_end).order(:wake_time)
    # unwoken(未就寝)
    @unwoken_record = current_user.sleep_records.unbedded.first

    aggregator = SleepRecordAggregator.new(@week_records)
    week_days = (week_start.to_date..week_end.to_date).to_a
    @weekly_records = aggregator.build_cumulative(week_days)

    @series = SleepRecordChartBuilder.new(@week_records).build_series(range: week_start..week_end)

    # 日ごと集計して平均を計算（累計 ÷ 記録のある日数）
    valid_days = @weekly_records.select { |d| d[:daily_sleep_hours].present? && d[:daily_wake_hours].present? }

    @weekly_average_sleep_hours = if valid_days.any?
      (valid_days.sum { |d| d[:daily_sleep_hours] } / valid_days.size).round(2)
    else
      0.0
    end

    @weekly_average_wake_hours = if valid_days.any?
      (valid_days.sum { |d| d[:daily_wake_hours] } / valid_days.size).round(2)
    else
      0.0
    end

    valid_wake_records  = @week_records.select { |r| r.wake_time.present? }
    valid_sleep_records = @week_records.select { |r| r.wake_time.present? && r.bed_time.present? }

    @weekly_average_wake_time = SleepRecordAggregator.new(valid_wake_records).average_time(:wake_time)
    @weekly_average_bed_time  = SleepRecordAggregator.new(valid_sleep_records).average_time(:bed_time)
  end
end
