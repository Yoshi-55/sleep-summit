class SleepRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_unwoken_record

  def create
    return redirect_with_flash(:alert, "すでに未就寝レコードがあります") if @unwoken_record
    create_wake_record
  end

  def update
    return redirect_with_flash(:alert, "未就寝レコードがありません") unless @unwoken_record
    update_bed_time
  end

  private

  def set_unwoken_record
    @unwoken_record = current_user.sleep_records.unbedded.first
  end

  def create_wake_record
    last_record = current_user.sleep_records.order(:wake_time).last
    if last_record && last_record.bed_time.nil?
      return redirect_with_flash(:alert, "前回の就寝時刻を先に記録してください")
    end

    sleep_record = current_user.sleep_records.build(wake_time: Time.current)
    if sleep_record.save
      redirect_with_flash(:notice, "起床時刻を記録しました")
    else
      redirect_with_flash(:alert, "起床時刻の記録に失敗しました: #{sleep_record.errors.full_messages.join(', ')}")
    end
  end

  def update_bed_time
    if @unwoken_record.update(bed_time: Time.current)
      redirect_with_flash(:notice, "就寝時刻を記録しました")
    else
      redirect_with_flash(:alert, "就寝時刻の記録に失敗しました: #{@unwoken_record.errors.full_messages.join(', ')}")
    end
  end

  def redirect_with_flash(type, message)
    redirect_to authenticated_root_path, flash: { type => message }
  end
end
