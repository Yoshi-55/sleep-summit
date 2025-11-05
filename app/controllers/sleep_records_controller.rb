class SleepRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_unwoken_record, only: [ :create ]
  before_action :set_sleep_record, only: [ :edit, :update ]

  def new
    @sleep_record = current_user.sleep_records.build
    
    if params[:date].present?
      date = Date.parse(params[:date])
      @sleep_record.wake_time = Time.zone.local(date.year, date.month, date.day, 6, 0)
      @sleep_record.bed_time = Time.zone.local(date.year, date.month, date.day, 22, 0)
    end
    
    session[:return_to] = request.referer
  end

  def create
    if params[:sleep_record].present?
      create_from_form
    else
      return redirect_with_flash(:alert, "すでに未就寝レコードがあります") if @unwoken_record
      create_wake_record
    end
  end

  def update
    if params[:record_type] == "bed_time"
      update_bed_time
    else
      update_sleep_record
    end
  end

  def edit
    session[:return_to] = request.referer
  end

  private

  def set_sleep_record
    @sleep_record = current_user.sleep_records.find(params[:id])
  end

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

  def create_from_form
    wake_time_param = params[:sleep_record][:wake_time]
    bed_time_param = params[:sleep_record][:bed_time]
    
    attributes = {}
    attributes[:wake_time] = Time.zone.parse(wake_time_param) if wake_time_param.present?
    attributes[:bed_time] = Time.zone.parse(bed_time_param) if bed_time_param.present?
    
    @sleep_record = current_user.sleep_records.build(attributes)
    
    if @sleep_record.save
      return_path = session.delete(:return_to) || authenticated_root_path
      redirect_to return_path, notice: "記録を作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update_bed_time
    unwoken_record = current_user.sleep_records.unbedded.first
    return redirect_with_flash(:alert, "未就寝レコードがありません") unless unwoken_record

    if unwoken_record.update(bed_time: Time.current)
      redirect_with_flash(:notice, "就寝時刻を記録しました")
    else
      redirect_with_flash(:alert, "就寝時刻の記録に失敗しました: #{unwoken_record.errors.full_messages.join(', ')}")
    end
  end

  def update_sleep_record
    wake_time_param = params[:sleep_record][:wake_time]
    bed_time_param = params[:sleep_record][:bed_time]
    
    attributes = {}
    attributes[:wake_time] = Time.zone.parse(wake_time_param) if wake_time_param.present?
    attributes[:bed_time] = Time.zone.parse(bed_time_param) if bed_time_param.present?
    
    if @sleep_record.update(attributes)
      return_path = session.delete(:return_to) || authenticated_root_path
      redirect_to return_path, notice: "記録を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def sleep_record_params
    params.require(:sleep_record).permit(:wake_time, :bed_time)
  end

  def redirect_with_flash(type, message)
    redirect_to authenticated_root_path, flash: { type => message }
  end
end
