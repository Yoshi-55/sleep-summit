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
    if days
      today = Date.today
      start_of_week = today - ((today.wday == 0 ? 6 : today.wday - 1)) # 月曜始まり
      cutoff = start_of_week.beginning_of_day
      end_of_week = (start_of_week + days).beginning_of_day
      records = records.select { |r| r.bed_time >= cutoff && r.bed_time < end_of_week }
    end

    cumulative_value = 0.0
    series = []

    records.sort_by(&:bed_time).each_with_index do |record, index|
      next unless record.bed_time
      wake_time = record.wake_time || Time.current
      sleep_hours = ((wake_time - record.bed_time) / 1.hour).round(2)

      series << [ record.bed_time.iso8601, cumulative_value ]
      cumulative_value -= sleep_hours
      series << [ wake_time.iso8601, cumulative_value ]

      next_bed_time = records[index + 1]&.bed_time
      if next_bed_time
        awake_hours = ((next_bed_time - wake_time) / 1.hour).round(2)
        series << [ wake_time.iso8601, cumulative_value ]
        cumulative_value += awake_hours
        series << [ next_bed_time.iso8601, cumulative_value ]
      end
    end

    series
  end

  def self.build_weekly_cumulative(records, days: 7)
    today = Date.today
    start_of_week = today - ((today.wday == 0 ? 6 : today.wday - 1)) # 月曜始まり
    cutoff = start_of_week.beginning_of_day
    end_of_week = (start_of_week + days).beginning_of_day
    recent_records = records.select { |r| r.bed_time >= cutoff && r.bed_time < end_of_week }
    week_days = (0...days).map { |i| start_of_week + i }
    build_cumulative(recent_records, week_days)
  end

  private

  def wake_time_after_bed_time
    return if bed_time.blank? || wake_time.blank?
    if wake_time <= bed_time
      errors.add(:wake_time, "無効な入力です。起床時間は就寝時間より後に設定してください。")
    end
  end
end
