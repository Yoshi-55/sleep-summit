class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @sleep_records = current_user.sleep_records.order(bed_time: :desc)
  end

  def start_sleep
    if current_user.sleep_records.where(wake_time: nil).exists?
      redirect_to authenticated_root_path, alert: "すでに就寝記録があります"
    else
      current_user.sleep_records.create!(bed_time: Time.current)
      redirect_to authenticated_root_path, notice: "就寝時刻を記録しました"
    end
  end

  def wake_up
    record = current_user.sleep_records.where(wake_time: nil).last
    if record
      record.update!(wake_time: Time.current)
      redirect_to authenticated_root_path, notice: "起床時刻を記録しました"
    else
      redirect_to authenticated_root_path, alert: "睡眠時刻の記録なし、起床時刻を記録できません"
    end
  end
end
