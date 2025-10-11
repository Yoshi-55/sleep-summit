class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    week_start = Date.current.beginning_of_week(:sunday).beginning_of_day
    week_end   = Date.current.end_of_week(:sunday).end_of_day

    @week_records = current_user.sleep_records.finished.where(wake_time: week_start..week_end).order(:wake_time)
    # unwoken(未就寝)
    @unwoken_record = current_user.sleep_records.unbedded.first

    @series = SleepRecord.build_series(@week_records, range: week_start..week_end)

    week_days = (week_start.to_date..week_end.to_date).to_a
    @weekly_records = SleepRecord.build_cumulative(@week_records, week_days)

    # 平均時間
    @weekly_average_wake_hours  = SleepRecord.average_wake_hours(@week_records)
    @weekly_average_sleep_hours = SleepRecord.average_sleep_hours(@week_records)

    # 平均時刻
    @weekly_average_wake_time = SleepRecord.average_time(@week_records.with_wake_time, :wake_time)
    @weekly_average_bed_time  = SleepRecord.average_time(@week_records, :bed_time)
  end
end
