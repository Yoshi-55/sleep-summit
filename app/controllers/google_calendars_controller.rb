class GoogleCalendarsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_google_authenticated, except: [ :disconnect ]
  before_action :set_calendar_service, except: [ :disconnect ]

  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @month_events = @calendar_service.fetch_month_events(@date)
  end

  def create
    # シンプルモードと詳細モードの両方に対応
    if params[:start_date_detail].present?
      # 詳細モード
      start_time = parse_datetime(params[:start_date_detail], params[:start_time_detail])
      end_time = parse_datetime(params[:end_date], params[:end_time_detail])
    else
      # シンプルモード（終了日は開始日と同じ）
      start_time = parse_datetime(params[:start_date], params[:start_time])
      end_time = parse_datetime(params[:start_date], params[:end_time])
    end

    if @calendar_service.create_event(
      summary: params[:summary],
      start_time: start_time,
      end_time: end_time,
      description: params[:description],
      location: params[:location]
    )
      redirect_to redirect_path, notice: "予定を作成しました"
    else
      redirect_to redirect_path, alert: "予定の作成に失敗しました"
    end
  end

  def update
    # プライマリカレンダーの予定のみ更新可能
    event = @calendar_service.fetch_event(params[:id])
    unless event
      redirect_to google_calendars_path, alert: "予定が見つかりませんでした"
      return
    end

    # シンプルモードと詳細モードの両方に対応
    if params[:edit_start_date].present?
      # シンプルモード（終了日は開始日と同じ）
      start_time = parse_datetime(params[:edit_start_date], params[:edit_start_time])
      end_time = parse_datetime(params[:edit_start_date], params[:edit_end_time])
    else
      # 詳細モード
      start_time = parse_datetime(params[:start_date], params[:start_time])
      end_time = parse_datetime(params[:end_date], params[:end_time])
    end

    if @calendar_service.update_event(
      event_id: params[:id],
      summary: params[:summary],
      start_time: start_time,
      end_time: end_time,
      description: params[:description],
      location: params[:location]
    )
      redirect_to google_calendars_path, notice: "予定を更新しました"
    else
      redirect_to google_calendars_path, alert: "予定の更新に失敗しました"
    end
  end

  def destroy
    # プライマリカレンダーの予定のみ削除可能
    event = @calendar_service.fetch_event(params[:id])
    unless event
      redirect_to google_calendars_path, alert: "予定が見つかりませんでした"
      return
    end

    if @calendar_service.delete_event(params[:id])
      redirect_to google_calendars_path, notice: "予定を削除しました"
    else
      redirect_to google_calendars_path, alert: "予定の削除に失敗しました"
    end
  end

  def disconnect
    current_user.disconnect_google
    redirect_to dashboard_path, notice: "Googleカレンダーとの連携を解除しました"
  end

  private

  def check_google_authenticated
    unless current_user.google_authenticated?
      redirect_to profile_path, alert: "Googleカレンダーと連携してください"
    end
  end

  def set_calendar_service
    @calendar_service = GoogleCalendarService.new(current_user)
  end

  def parse_datetime(date_str, time_str)
    Time.zone.parse("#{date_str} #{time_str}")
  end

  def redirect_path
    # リファラーがダッシュボードの場合はダッシュボードに戻す
    if request.referer&.include?("dashboard")
      dashboard_path
    else
      google_calendars_path
    end
  end
end
