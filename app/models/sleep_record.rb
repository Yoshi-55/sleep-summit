class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :wake_time, presence: true
  validate :bed_time_after_wake_time

  scope :unbedded, -> { where(bed_time: nil) }
  scope :with_wake_time, -> { where.not(wake_time: nil) }
  scope :finished, -> { where.not(bed_time: nil) }

  def self.build_cumulative(records, days_range)
    return [] if records.empty?

    sorted_records = records.with_wake_time.order(:wake_time)
    records_by_date = records.group_by { |r| r.wake_time&.to_date }.compact

    days_range.map do |day|
      day_records = records_by_date[day] || []
      records_until_day = sorted_records.where("wake_time <= ?", day.end_of_day)

      cumulative_sleep, cumulative_wake = calculate_cumulative_times(records_until_day)

      day_records.any? ?
        build_day_data(day_records, sorted_records, cumulative_sleep, cumulative_wake) :
        build_empty_day_data(day, cumulative_sleep, cumulative_wake)
    end
  end

  def self.build_weekly_cumulative(records, days: 7)
    week_range = get_week_range(days)
    recent_records = records.where(wake_time: week_range)
    week_days = week_range.begin.to_date..(week_range.begin.to_date + days - 1)
    build_cumulative(recent_records, week_days.to_a)
  end

  def self.build_series(records, days: nil)
    filtered_records = days ? records.where(wake_time: get_week_range(days)) : records
    ordered_records = filtered_records.with_wake_time.order(:wake_time)

    cumulative_value = 0.0
    series = []

    ordered_records.includes(:user).each_with_index do |record, index|
      series << [ record.wake_time.iso8601, cumulative_value ]

      bed_time = record.bed_time || Time.current
      awake_hours = time_diff_hours(record.wake_time, bed_time)
      cumulative_value += awake_hours
      series << [ bed_time.iso8601, cumulative_value ]

      next_record = ordered_records[index + 1]
      if next_record&.wake_time && record.bed_time
        sleep_hours = time_diff_hours(record.bed_time, next_record.wake_time)
        cumulative_value -= sleep_hours
        series << [ next_record.wake_time.iso8601, cumulative_value ]
      end
    end

    series
  end

  def self.total_sleep_hours(records)
    return 0.0 if records.empty?

    ordered_records = records.with_wake_time.order(:wake_time)
    cumulative_sleep, _ = calculate_cumulative_times(ordered_records)
    cumulative_sleep
  end

  def self.total_wake_hours(records)
    return 0.0 if records.empty?

    ordered_records = records.with_wake_time.order(:wake_time)
    _, cumulative_wake = calculate_cumulative_times(ordered_records)
    cumulative_wake
  end

  private

  def self.calculate_cumulative_times(records)
    return [ 0.0, 0.0 ] if records.empty?

    cumulative_sleep = 0.0
    cumulative_wake = 0.0
    ordered_records = records.is_a?(ActiveRecord::Relation) ? records.to_a : records

    ordered_records.each_with_index do |record, index|
      end_time = record.bed_time || Time.current
      cumulative_wake += time_diff_hours(record.wake_time, end_time)

      next_record = ordered_records[index + 1]
      if record.bed_time && next_record
        cumulative_sleep += time_diff_hours(record.bed_time, next_record.wake_time)
      end
    end

    [ cumulative_sleep, cumulative_wake ]
  end

  def self.build_day_data(day_records, all_records, cumulative_sleep, cumulative_wake)
    first_record = day_records.min_by(&:wake_time)
    last_record = day_records.max_by(&:wake_time)

    {
      day: first_record.wake_time.to_date,
      wake_times: [ format_time(first_record.wake_time) ],
      bed_times: last_record.bed_time ? [ format_time(last_record.bed_time) ] : [],
      daily_sleep_hours: calculate_daily_sleep(first_record, all_records),
      daily_wake_hours: calculate_daily_wake(first_record, last_record),
      cumulative_sleep_hours: format_cumulative(cumulative_sleep),
      cumulative_wake_hours: format_cumulative(cumulative_wake)
    }
  end

  def self.build_empty_day_data(day, cumulative_sleep, cumulative_wake)
    {
      day: day,
      wake_times: [],
      bed_times: [],
      daily_sleep_hours: nil,
      daily_wake_hours: nil,
      cumulative_sleep_hours: nil,
      cumulative_wake_hours: nil
    }
  end

  def self.calculate_daily_sleep(first_record, all_records)
    index = all_records.index(first_record)
    return nil unless index&.positive?

    prev_record = all_records[index - 1]
    return nil unless prev_record.bed_time

    time_diff_hours(prev_record.bed_time, first_record.wake_time)
  end

  def self.calculate_daily_wake(first_record, last_record)
    end_time = last_record.bed_time || Time.current
    time_diff_hours(first_record.wake_time, end_time)
  end

  def self.get_week_range(days)
    today = Date.current
    start_of_week = today.beginning_of_week(:monday)
    start_of_week.beginning_of_day...(start_of_week + days.days).beginning_of_day
  end

  # 時間差計算（日跨ぎ対応）
  def self.time_diff_hours(start_time, end_time)
    return 0.0 unless start_time && end_time

    seconds = end_time.to_time - start_time.to_time
    hours = seconds / 3600.0
    result = [ hours, 0.0 ].max.round(2)

    result
  end
  end
end
