require 'date'

puts "ユーザー作成開始..."

User.create!(
  [
    { name: "Guest1", email: "test1@example.com", password: "password" },
    { name: "Guest2", email: "test2@example.com", password: "password" }
  ]
)

puts "ユーザー作成完了！"

puts "SleepRecord データ生成..."

User.find_each do |user|
  start_date = 2.months.ago.to_date
  end_date   = Date.yesterday
  prev_bed_time = nil

  (start_date..end_date).each do |date|
    wake_time = Time.zone.local(date.year, date.month, date.day, rand(5..9), rand(0..59))

    wake_time = [ wake_time, prev_bed_time + 6.hours ].max if prev_bed_time

    bed_hour = rand(22..26)
    bed_day  = date + (bed_hour >= 24 ? 1 : 0)
    bed_hour = bed_hour % 24
    bed_min  = rand(0..59)
    bed_time = Time.zone.local(bed_day.year, bed_day.month, bed_day.day, bed_hour, bed_min)

    bed_time += 1.day if bed_time <= wake_time

    SleepRecord.create!(
      user: user,
      wake_time: wake_time,
      bed_time: bed_time
    )

    prev_bed_time = bed_time
  end

  puts "user_id=#{user.id} の SleepRecord 作成完了"
end

puts "全SleepRecord の作成が完了しました！"
