class SleepRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_unwoken_record, only: [ :update ]

  def index
    @sleep_records = current_user.sleep_records.order(:bed_time)
    @unwoken_record = current_user.sleep_records.unwoken.first

    @series = SleepRecord.build_series(@sleep_records, days: 7)

    @weekly_records = SleepRecord.build_weekly_cumulative(@sleep_records, days: 7)

    finished_records = @sleep_records.select(&:wake_time)
    @today_sleep = finished_records.find { |r| r.bed_time >= Time.current.beginning_of_day && r.wake_time <= Time.current.end_of_day }
    @total_sleep_hours = SleepRecord.total_sleep_hours(finished_records)
    @average_sleep_hours = finished_records.any? ? (@total_sleep_hours / finished_records.size).round(2) : 0
  end

  def create
    if @unwoken_record
      redirect_with_flash(:alert, "すでに未起床レコードがあります") and return
    end

    current_user.sleep_records.create!(bed_time: Time.current)
    redirect_with_flash(:notice, "就寝時刻を記録しました")
  end

  def update
    if @unwoken_record
      @unwoken_record.update!(wake_time: Time.current)
      redirect_with_flash(:notice, "起床時刻を記録しました")
    else
      redirect_with_flash(:alert, "未起床レコードがありません")
    end
  end

  private

  def set_unwoken_record
    @unwoken_record = current_user.sleep_records.unwoken.first
  end

  def redirect_with_flash(type, message)
    redirect_to authenticated_root_path, flash: { type => message }
  end
end
