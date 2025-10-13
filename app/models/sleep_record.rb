class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :wake_time, presence: true
  validate :bed_time_after_wake_time

  scope :unbedded, -> { where(bed_time: nil) }
  scope :with_wake_time, -> { where.not(wake_time: nil) }
  scope :finished, -> { where.not(bed_time: nil) }

  def self.average_sleep_hours(records)
    return 0.0 if records.empty?
    (total_sleep_hours(records) / records.size).round(2)
  end

  def self.average_wake_hours(records)
    return 0.0 if records.empty?
    (total_wake_hours(records) / records.size).round(2)
  end

  def self.average_time(records, column)
    return nil if records.empty?

    total_seconds = records.sum do |r|
      t = r.send(column)
      next 0 unless t

      sec = t.hour * 3600 + t.min * 60 + t.sec
      sec += 24 * 3600 if column == :bed_time && t.hour < 6
      sec
    end

    avg_sec = total_seconds / records.size
    avg_sec -= 24 * 3600 if avg_sec >= 24 * 3600

    hours = (avg_sec / 3600).to_i
    minutes = ((avg_sec % 3600) / 60).to_i
    sprintf("%02d:%02d", hours, minutes)
  end


  def self.total_sleep_hours(records)
    cumulative_times(records).first
  end

  def self.total_wake_hours(records)
    cumulative_times(records).last
  end


  # 日別累計
  def self.build_cumulative(records, days_range)
    return [] if records.empty?

    sorted = records.with_wake_time.order(:wake_time)

    prev_record = records.first&.user&.sleep_records
                  &.where("wake_time < ?", sorted.first.wake_time)
                  &.order(wake_time: :desc)
                  &.first

    all_records = [ prev_record, *sorted ].compact
    records_by_date = records.group_by { |r| r.wake_time&.to_date }.compact

    days_range.map do |day|
      day_records = records_by_date[day] || []
      until_day_records = all_records.select { |r| r.wake_time <= day.end_of_day }
      sleep_total, wake_total = cumulative_times(until_day_records)

      if day == days_range.first && day_records.any?
        first_record = day_records.first
        first_sleep = daily_sleep(first_record, sorted)
        sleep_total += first_sleep if first_sleep
      end

      if day_records.any?
        build_day_data(day_records, all_records, sleep_total, wake_total)

      else
        build_empty_day_data(day, sleep_total, wake_total)
      end
    end
  end

  # グラフ用データ
  def self.build_series(records, range: nil, days: nil)
    filtered = if range
      records.where(wake_time: range)
    elsif days
      records.where(wake_time: get_week_range(days))
    else
      records
    end
    ordered = filtered.with_wake_time.order(:wake_time)

    series = []
    cumulative = 0.0

    ordered.each_with_index do |record, i|
      series << [ record.wake_time.iso8601, cumulative ]

      bed_time = record.bed_time || Time.current
      awake_hours = time_diff_hours(record.wake_time, bed_time)
      cumulative += awake_hours
      series << [ bed_time.iso8601, cumulative ]

      next_rec = ordered[i + 1]
      if record.bed_time && next_rec&.wake_time
        sleep_hours = time_diff_hours(record.bed_time, next_rec.wake_time)
        cumulative -= sleep_hours
        series << [ next_rec.wake_time.iso8601, cumulative ]
      end
    end

    series
  end

  private

    # 日別データ
    def self.build_day_data(day_records, all_records, cumulative_sleep, cumulative_wake)
      first = day_records.min_by(&:wake_time)
      last = day_records.max_by(&:wake_time)

      {
        day: first.wake_time.to_date,
        wake_times: [ format_time(first.wake_time) ],
        bed_times: last.bed_time ? [ format_time(last.bed_time) ] : [],
        daily_sleep_hours: daily_sleep(first, all_records),
        daily_wake_hours: daily_wake(first, last),
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

    # 日ごとの睡眠/活動
    def self.daily_sleep(first, all_records)
      idx = all_records.index(first)
      return nil unless idx&.positive?

      prev = all_records[idx - 1]
      return nil unless prev.bed_time

      time_diff_hours(prev.bed_time, first.wake_time)
    end

    def self.daily_wake(first, last)
      end_time = last.bed_time || Time.current
      time_diff_hours(first.wake_time, end_time)
    end

    # 総睡眠・総起床計算
    def self.cumulative_times(records)
      return [ 0.0, 0.0 ] if records.empty?

      sleep_total = 0.0
      wake_total = 0.0
      ordered = records.is_a?(ActiveRecord::Relation) ? records.to_a : records

      ordered.each_with_index do |rec, i|
        end_time = rec.bed_time || Time.current
        wake_total += time_diff_hours(rec.wake_time, end_time)

        next_rec = ordered[i + 1]
        sleep_total += time_diff_hours(rec.bed_time, next_rec.wake_time) if rec.bed_time && next_rec
      end

      [ sleep_total, wake_total ]
    end

    # 時間差計算（hours, 2桁で丸め）
    def self.time_diff_hours(start_time, end_time)
      return 0.0 unless start_time && end_time

      seconds = end_time.to_time - start_time.to_time
      [ (seconds / 3600.0).round(2), 0.0 ].max
    end

    def self.format_time(time)
      time&.strftime("%m/%d %H:%M")
    end

    def self.format_cumulative(value)
      return nil unless value.positive?
      v = value.round(2)
      v % 1 == 0 ? v.to_i.to_s : sprintf("%.2f", v)
    end

    def self.get_week_range(days)
      today = Date.current
      start_of_week = today.beginning_of_week(:monday)
      start_of_week.beginning_of_day...(start_of_week + days.days).beginning_of_day
    end


    def bed_time_after_wake_time
      return if wake_time.blank? || bed_time.blank?

      if bed_time >= wake_time
        return
      elsif bed_time.to_date > wake_time.to_date
        return
      end

      errors.add(:bed_time, "無効な入力です。就寝時間は起床時間より後に設定してください。")
    end
end
