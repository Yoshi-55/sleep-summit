# ⚠️デプロイ後サンプルデータ作成用
# ⚠️MVP使用後はrootと本コントローラーをコメントアウトor削除する
class SeedsController < ApplicationController
  def sample_data
    sample_users = [
      { name: "Guest1", email: "test1111@example.com", password: "password" },
      { name: "Guest2", email: "test2222@example.com", password: "password" }
    ]

    sample_users.each do |attrs|
      user = User.find_or_create_by!(email: attrs[:email]) do |u|
        u.name     = attrs[:name]
        u.password = attrs[:password]
      end

      user.sleep_records.destroy_all

      start_date = 2.months.ago.to_date
      end_date   = Date.yesterday
      prev_bed_time = nil

      (start_date..end_date).each do |date|
        # 起床時刻: 5〜9時
        wake_time = Time.zone.local(date.year, date.month, date.day, rand(5..9), rand(0..59))
        wake_time = [ wake_time, prev_bed_time + 6.hours ].max if prev_bed_time

        # 就寝時刻: 22〜26時
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
    end

    render plain: "サンプルデータを再作成完了"
  end
end
