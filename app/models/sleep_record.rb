class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :bed_time, presence: true
  validate :wake_time_after_bed_time
  validates :note, length: { maximum: 100 }, allow_blank: true

  scope :unwoken, -> { where(wake_time: nil) }

  def self.total_sleep_hours(records)
    records.select(&:wake_time).sum { |r| ((r.wake_time - r.bed_time)/1.hour).round(2) }
  end

  def self.build_series(records, days: nil)
    if days
      cutoff = Time.current.beginning_of_day - (days - 1).days
      records = records.select { |r| r.bed_time >= cutoff }
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
    return [] if records.blank?

    cutoff = Time.current.beginning_of_day - (days - 1).days
    recent_records = records.select { |r| r.bed_time >= cutoff }.sort_by(&:bed_time)

    cumulative_sleep = 0.0
    cumulative_wake = 0.0

    recent_records.group_by { |r| r.bed_time.to_date }.map do |day, day_records|
      day_records.each_with_index do |r, index|
        next unless r.wake_time

        sleep_hours = ((r.wake_time - r.bed_time) / 1.hour).round(2)
        cumulative_sleep += sleep_hours

        next_bed_time = records.find { |nr| nr.bed_time > r.wake_time }&.bed_time

        awake_hours = if next_bed_time
                        ((next_bed_time - r.wake_time)/1.hour).round(2)
        else
                        ((Time.current - r.wake_time)/1.hour).round(2)
        end
        cumulative_wake += awake_hours
      end

      {
        day: day,
        bed_times: day_records.map { |r| r.bed_time.strftime("%H:%M") },
        wake_times: day_records.map { |r| r.wake_time&.strftime("%H:%M") },
        cumulative_sleep_hours: cumulative_sleep.round(2),
        cumulative_wake_hours: cumulative_wake.round(2)
      }
    end.sort_by { |r| r[:day] }
  end

  private

  def wake_time_after_bed_time
    return if bed_time.blank? || wake_time.blank?
    if wake_time <= bed_time
      errors.add(:wake_time, "無効な入力です。起床時間は就寝時間より後に設定してください。")
    end
  end
end
