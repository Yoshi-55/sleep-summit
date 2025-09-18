class SleepRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_unwoken_record, only: [:update]

  def index
    @sleep_records = current_user.sleep_records.order(:bed_time)

    @unwoken_record = @sleep_records.find { |r| r.wake_time.nil? }

    display_records = @sleep_records.select { |r| r.bed_time.present? }
    @record_cumulative = build_record_cumulative(display_records)

    valid_records = display_records.select { |r| r.wake_time.present? }
    today_start = Time.current.beginning_of_day
    today_end   = Time.current.end_of_day
    @today_sleep = valid_records.find { |r| r.bed_time >= today_start && r.wake_time <= today_end }

    @total_sleep_hours = valid_records.sum { |r| ((r.wake_time - r.bed_time)/1.hour).round(2) }
    @average_sleep_hours = valid_records.any? ? (@total_sleep_hours / valid_records.size).round(2) : 0

    @series = build_series(valid_records)
  end

  def create
    if current_user.sleep_records.find { |r| r.wake_time.nil? }
      redirect_to authenticated_root_path, alert: "すでに未起床レコードがあります"
    else
      current_user.sleep_records.create!(bed_time: Time.current)
      redirect_to authenticated_root_path, notice: "就寝時刻を記録しました"
    end
  end

  def update
    if @sleep_record
      @sleep_record.update!(wake_time: Time.current)
      redirect_to authenticated_root_path, notice: "起床時刻を記録しました"
    else
      redirect_to authenticated_root_path, alert: "未起床レコードがありません"
    end
  end

  private

  def set_unwoken_record
    @sleep_record = current_user.sleep_records.find { |r| r.wake_time.nil? }
  end

  def build_series(records)
    cumulative_value = 0.0
    series = []

    records.each_with_index do |record, index|
      next_bed_time = records[index + 1]&.bed_time
      if next_bed_time && record.wake_time
        total_hours = ((next_bed_time - record.wake_time)/1.hour).round(2)
        series << [record.wake_time.iso8601, cumulative_value]
        series << [next_bed_time.iso8601, cumulative_value + total_hours]
        cumulative_value += total_hours
      end
      if record.wake_time && record.bed_time
        sleep_hours = ((record.wake_time - record.bed_time)/1.hour).round(2)
        series << [record.bed_time.iso8601, cumulative_value]
        series << [record.wake_time.iso8601, cumulative_value - sleep_hours]
        cumulative_value -= sleep_hours
      end
    end

    series
  end

  def build_record_cumulative(records)
    records.each_with_index.map do |record, index|
      next_bed_time = records[index + 1]&.bed_time
      sleep_hours = record.wake_time && record.bed_time ? ((record.wake_time - record.bed_time)/1.hour).round(2) : 0
      awake_hours = next_bed_time && record.wake_time ? ((next_bed_time - record.wake_time)/1.hour).round(2) : 0

      {
        day: record.wake_time&.to_date || record.bed_time.to_date,
        wake_time: record.wake_time,
        bed_time: record.bed_time,
        next_bed_time: next_bed_time,
        awake_time: awake_hours,
        sleep_time: sleep_hours
      }
    end
  end
end