class SleepRecordChartBuilder
  def initialize(records)
    @records = records
  end

  def build_series(range: nil, days: nil)
    # グラフデータの生成
    filtered = if range
      @records.select { |r| r.wake_time && range.cover?(r.wake_time) }
    elsif days
      week_range = get_week_range(days)
      @records.select { |r| r.wake_time && week_range.cover?(r.wake_time) }
    else
      @records
    end
    ordered = filtered.select { |r| r.wake_time.present? }.sort_by(&:wake_time)
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
      end
    end
    series
  end

  private

  def time_diff_hours(start_time, end_time)
    return 0.0 unless start_time && end_time
    seconds = end_time.to_time - start_time.to_time
    [ (seconds / 3600.0).round(2), 0.0 ].max
  end

  def get_week_range(days)
    today = Date.current
    start_of_week = today.beginning_of_week(:monday)
    start_of_week.beginning_of_day...(start_of_week + days.days).beginning_of_day
  end
end
