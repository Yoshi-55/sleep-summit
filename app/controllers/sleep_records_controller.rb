class SleepRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_unwoken_record, only: [ :update ]

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
