class HistoryController < ApplicationController
  before_action :authenticate_user!

  def index
    sleep_records = current_user.sleep_records.order(:bed_time)
    months = (0..11).map { |i| Date.today.prev_month(i) }.sort.reverse

    @monthly_records_list = []
    @monthly_series_list = []

    months.each do |month|
      month_start = month.beginning_of_month
      month_end = month.end_of_month
      month_records = sleep_records.select { |r| r.bed_time.to_date >= month_start && r.bed_time.to_date <= month_end }
      records = SleepRecord.build_monthly_cumulative(month_records, date: month)
      if records.any? { |r| r[:bed_times].present? || r[:wake_times].present? }
        @monthly_records_list << { month: month, records: records }
        @monthly_series_list << { month: month, series: SleepRecord.build_series(month_records) }
      end
    end
  end
end
