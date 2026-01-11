class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :set_today_events

  def index
    week_start = Date.current.beginning_of_week(:sunday).beginning_of_day
    week_end   = Date.current.end_of_week(:sunday).end_of_day

    @week_records = current_user.sleep_records.finished.where(wake_time: week_start..week_end).order(:wake_time)
    # unwoken(未就寝)
    @unwoken_record = current_user.sleep_records.unbedded.first

    aggregator = SleepRecordAggregator.new(@week_records)
    week_days = (week_start.to_date..week_end.to_date).to_a
    @weekly_records = aggregator.build_cumulative(week_days, exclude_prev_record: true)

    @series = SleepRecordChartBuilder.new(@week_records).build_series(range: week_start..week_end)

    averages = aggregator.average_daily_hours(@weekly_records, exclude_today: true)
    @weekly_average_wake_hours = averages[:wake]
    @weekly_average_sleep_hours = averages[:sleep]

    valid_wake_records = @week_records.select { |r| r.wake_time.present? && r.wake_time.to_date < Date.current }
    valid_sleep_records = @week_records.select { |r| r.wake_time.present? && r.bed_time.present? && r.wake_time.to_date < Date.current }

    @weekly_average_wake_time = SleepRecordAggregator.new(valid_wake_records).average_time(:wake_time)
    @weekly_average_bed_time = SleepRecordAggregator.new(valid_sleep_records).average_time(:bed_time)
  end

  private

  def set_today_events
    if current_user.google_authenticated?
      begin
        calendar_service = GoogleCalendarService.new(current_user)
        @today_events = calendar_service.fetch_today_events
      rescue StandardError => e
        Rails.logger.error "Google Calendar fetch error: #{e.message}"
        @today_events = []
      end
    else
      @today_events = []
    end
  end
end
