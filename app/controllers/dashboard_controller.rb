class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    sleep_records = current_user.sleep_records.includes(:user).order(:wake_time)
    finished_records = sleep_records.finished

    @unwoken_record = sleep_records.unbedded.first
    @series = SleepRecord.build_series(sleep_records, days: 7)
    @weekly_records = SleepRecord.build_weekly_cumulative(sleep_records, days: 7)
    @today_sleep = find_today_sleep_record(finished_records)

    @average_sleep_hours = calculate_average_sleep_hours(finished_records)
    @average_wake_hours = calculate_average_wake_hours(finished_records)

    @weekly_average_sleep_hours = calculate_weekly_average_sleep_hours
    @weekly_average_wake_hours = calculate_weekly_average_wake_hours

    @average_wake_time = calculate_average_wake_time(sleep_records.with_wake_time)
    @average_bed_time = calculate_average_bed_time(finished_records)

    @weekly_cumulative_wake_hours = calculate_weekly_cumulative_wake_hours
    @weekly_cumulative_sleep_hours = calculate_weekly_cumulative_sleep_hours
  end

  private

  def find_today_sleep_record(records)
    today = Date.current
    records.find_by("DATE(wake_time) = ?", today)
  end

  def calculate_average_sleep_hours(records)
    return 0.0 if records.empty?
    total_sleep_hours = SleepRecord.total_sleep_hours(records)
    (total_sleep_hours / records.size).round(2)
  end

  def calculate_average_wake_hours(records)
    return 0.0 if records.empty?
    total_wake_hours = records.sum { |record| SleepRecord.calculate_daily_wake(record, record) || 0 }
    (total_wake_hours / records.size).round(2)
  end

  def calculate_weekly_average_sleep_hours
    return nil if @weekly_records.empty?
    sleep_hours = @weekly_records.map { |r| r[:daily_sleep_hours] }.compact
    return nil if sleep_hours.empty?
    (sleep_hours.sum / sleep_hours.size).round(2)
  end

  def calculate_weekly_average_wake_hours
    return nil if @weekly_records.empty?
    wake_hours = @weekly_records.map { |r| r[:daily_wake_hours] }.compact
    return nil if wake_hours.empty?
    (wake_hours.sum / wake_hours.size).round(2)
  end

  def calculate_average_wake_time(records)
    return nil if records.empty?
    total_seconds = records.sum do |record|
      time = record.wake_time.in_time_zone
      time.hour * 3600 + time.min * 60 + time.sec
    end
    average_seconds = total_seconds / records.size
    hours = (average_seconds / 3600).to_i
    minutes = ((average_seconds % 3600) / 60).to_i
    hours -= 24 if hours >= 24
    sprintf("%02d:%02d", hours, minutes)
  end

  def calculate_average_bed_time(records)
    return nil if records.empty?
    total_seconds = records.sum do |record|
      time = record.bed_time.in_time_zone
      seconds = time.hour * 3600 + time.min * 60 + time.sec
      seconds += 24 * 3600 if time.hour < 6  # 深夜0-6時を翌日扱い
      seconds
    end
    average_seconds = total_seconds / records.size
    average_seconds -= 24 * 3600 if average_seconds >= 24 * 3600
    hours = (average_seconds / 3600).to_i
    minutes = ((average_seconds % 3600) / 60).to_i
    sprintf("%02d:%02d", hours, minutes)
  end

  def calculate_weekly_cumulative_wake_hours
    return nil if @weekly_records.empty?
    latest_record = @weekly_records.last
    latest_record[:cumulative_wake_hours]&.to_f || 0.0
  end

  def calculate_weekly_cumulative_sleep_hours
    return nil if @weekly_records.empty?
    latest_record = @weekly_records.last
    latest_record[:cumulative_sleep_hours]&.to_f || 0.0
  end
end
