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

  def wake_time_after_bed_time
    return if bed_time.blank? || wake_time.blank?
    if wake_time <= bed_time
      errors.add(:wake_time, "無効な入力です。起床時間は就寝時間より後に設定してください。")
    end
  end
end
