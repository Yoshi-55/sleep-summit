class HistoryController < ApplicationController
  before_action :authenticate_user!

  def index
    sleep_records = current_user.sleep_records.order(bed_time: :desc)

    @records = sleep_records.group_by { |r| r.bed_time.to_date }.transform_values do |day_records|
      sleep_hours = day_records.sum { |r| r.wake_time ? ((r.wake_time - r.bed_time)/1.hour).round(2) : 0 }
      wake_hours  = day_records.each_cons(2).sum { |prev, nxt| ((nxt.bed_time - prev.wake_time)/1.hour).round(2) rescue 0 }
      wake_hours += ((Time.current - day_records.last.wake_time)/1.hour).round(2) if day_records.last.wake_time && day_records.last.wake_time < Time.current
      activity_hours = wake_hours - sleep_hours

      {
        records: day_records,
        cumulative_sleep: sleep_hours.round(2),
        cumulative_wake: wake_hours.round(2),
        cumulative_activity: activity_hours.round(2)
      }
    end
  end
end