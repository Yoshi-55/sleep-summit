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
      return redirect_with_flash(:alert, I18n.t("sleep_records.create.already_has_unwoken_record")) if @unwoken_record
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
      return redirect_with_flash(:alert, I18n.t("sleep_records.create.need_previous_bed_time"))
    end

    sleep_record = current_user.sleep_records.build(wake_time: Time.current)
    if sleep_record.save
      redirect_with_flash(:notice, I18n.t("sleep_records.create.wake_time_recorded"))
    else
      redirect_with_flash(:alert, I18n.t("sleep_records.create.wake_time_failed", errors: sleep_record.errors.full_messages.join(", ")))
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
      render json: { success: true, redirect_url: return_path }, status: :ok
    else
      render json: { errors: @sleep_record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_bed_time
    unwoken_record = current_user.sleep_records.unbedded.first
    return redirect_with_flash(:alert, I18n.t("sleep_records.update.no_unwoken_record")) unless unwoken_record

    if unwoken_record.update(bed_time: Time.current)
      redirect_with_flash(:notice, I18n.t("sleep_records.update.bed_time_recorded"))
    else
      redirect_with_flash(:alert, I18n.t("sleep_records.update.bed_time_failed", errors: unwoken_record.errors.full_messages.join(", ")))
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
      render json: { success: true, redirect_url: return_path }, status: :ok
    else
      render json: { errors: @sleep_record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def sleep_record_params
    params.require(:sleep_record).permit(:wake_time, :bed_time)
  end

  def redirect_with_flash(type, message)
    redirect_to authenticated_root_path, flash: { type => message }
  end
end
