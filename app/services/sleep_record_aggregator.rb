class SleepRecordAggregator
  def initialize(records)
    @records = records
  end

  def average_sleep_hours
    return 0.0 if @records.empty?
    (total_sleep_hours / @records.size).round(2)
  end

  def average_wake_hours
    return 0.0 if @records.empty?
    (total_wake_hours / @records.size).round(2)
  end

  def average_time(column)
    return nil if @records.empty?

    seconds_list = @records.map do |r|
      t = r.send(column)
      next nil unless t
      t.hour * 3600 + t.min * 60 + t.sec
    end.compact

    return nil if seconds_list.empty?

    # 就寝時刻の場合、深夜0-6時を翌日扱いにする
    if column == :bed_time
      seconds_list.map! { |sec| sec < 6 * 3600 ? sec + 24 * 3600 : sec }
    end

    avg_sec = seconds_list.sum / seconds_list.size
    avg_sec %= 24 * 3600  # 24時間を超えた分を切り捨て

    sprintf("%02d:%02d", avg_sec / 3600, (avg_sec % 3600) / 60)
  end

  def total_sleep_hours
    sleep_total, = cumulative_times(@records)
    sleep_total
  end

  def total_wake_hours
    _, wake_total = cumulative_times(@records)
    wake_total
  end

  def build_cumulative(days_range, exclude_prev_record: false)
    return [] if @records.empty?
    sorted = @records.select { |r| r.wake_time.present? }.sort_by(&:wake_time)

    prev_record = if !exclude_prev_record && sorted.first
      user = sorted.first.user
      range_start = days_range.first
      if range_start == range_start.beginning_of_month
        nil
      else
        month_start = range_start.beginning_of_month
        user.sleep_records.where("wake_time >= ? AND wake_time < ?", month_start, sorted.first.wake_time).order(wake_time: :desc).first
      end
    end

    all_records = [ prev_record, *sorted ].compact
    records_by_date = @records.group_by { |r| r.wake_time&.to_date }.compact
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

  def average_daily_hours(daily_records, exclude_today: true)
    valid_wake_days = daily_records.select do |d|
      d[:day].is_a?(Date) &&
        (!exclude_today || d[:day] < Date.current) &&
        d[:daily_wake_hours].present?
    end

    valid_sleep_days = daily_records.select do |d|
      d[:day].is_a?(Date) &&
        (!exclude_today || d[:day] < Date.current) &&
        d[:daily_sleep_hours].present?
    end

    {
      wake: valid_wake_days.any? ? (valid_wake_days.sum { |d| d[:daily_wake_hours] } / valid_wake_days.size).round(2) : 0.0,
      sleep: valid_sleep_days.any? ? (valid_sleep_days.sum { |d| d[:daily_sleep_hours] } / valid_sleep_days.size).round(2) : 0.0
    }
  end

  private

  def build_day_data(day_records, all_records, cumulative_sleep, cumulative_wake)
    first = day_records.min_by(&:wake_time)
    last = day_records.max_by(&:wake_time)
    {
      id: first.id,
      day: first.wake_time.to_date,
      wake_times: [ format_time(first.wake_time) ],
      bed_times: last.bed_time ? [ format_time(last.bed_time) ] : [],
      daily_sleep_hours: daily_sleep(first, all_records),
      daily_wake_hours: daily_wake(first, last),
      cumulative_sleep_hours: format_cumulative(cumulative_sleep),
      cumulative_wake_hours: format_cumulative(cumulative_wake)
    }
  end

  def build_empty_day_data(day, cumulative_sleep, cumulative_wake)
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

  def daily_sleep(first, all_records)
    idx = all_records.index(first)
    return nil unless idx&.positive?
    prev = all_records[idx - 1]
    return nil unless prev.bed_time
    time_diff_hours(prev.bed_time, first.wake_time)
  end

  def daily_wake(first, last)
    end_time = last.bed_time || Time.current
    time_diff_hours(first.wake_time, end_time)
  end

  def cumulative_times(records)
    return [ 0.0, 0.0 ] if records.empty?
    sleep_total = 0.0
    wake_total = 0.0
    ordered = (records.is_a?(ActiveRecord::Relation) ? records.to_a : records).sort_by { |r| r.wake_time }
    ordered.each_with_index do |rec, i|
      end_time = rec.bed_time || Time.current
      wake_total += time_diff_hours(rec.wake_time, end_time)
      next_rec = ordered[i + 1]
      sleep_total += time_diff_hours(rec.bed_time, next_rec.wake_time) if rec.bed_time && next_rec
    end
    [ sleep_total, wake_total ]
  end

  def time_diff_hours(start_time, end_time)
    return 0.0 unless start_time && end_time
    seconds = end_time.to_time - start_time.to_time
    [ (seconds / 3600.0).round(2), 0.0 ].max
  end

  def format_time(time)
    time&.strftime("%m/%d %H:%M")
  end

  def format_cumulative(value)
    return nil unless value.positive?
    v = value.round(2)
    v % 1 == 0 ? v.to_i.to_s : sprintf("%.2f", v)
  end
end
