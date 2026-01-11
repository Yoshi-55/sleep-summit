require 'rails_helper'

RSpec.describe SleepRecordAggregator do
  describe '#average_daily_hours' do
    let(:today) { Date.new(2024, 1, 15) }

    before do
      travel_to Time.zone.local(2024, 1, 15, 12, 0, 0)
    end

    after do
      travel_back
    end

    context '起床と睡眠が両方ある日とない日が混在している場合' do
      let(:daily_records) do
        [
          { day: Date.new(2024, 1, 10), daily_wake_hours: 17.0, daily_sleep_hours: 8.0 },
          { day: Date.new(2024, 1, 11), daily_wake_hours: 16.0, daily_sleep_hours: nil },
          { day: Date.new(2024, 1, 12), daily_wake_hours: 16.0, daily_sleep_hours: 7.0 },
          { day: Date.new(2024, 1, 13), daily_wake_hours: nil, daily_sleep_hours: 9.0 },
          { day: Date.new(2024, 1, 14), daily_wake_hours: 15.0, daily_sleep_hours: 7.5 }
        ]
      end

      it '起床時間と睡眠時間を別々に平均計算する' do
        aggregator = SleepRecordAggregator.new([])
        result = aggregator.average_daily_hours(daily_records, exclude_today: false)

        expect(result[:wake]).to eq(16.0)
        expect(result[:sleep]).to eq(7.88)
      end
    end

    context '今日のデータを除外する場合' do
      let(:daily_records) do
        [
          { day: Date.new(2024, 1, 13), daily_wake_hours: 16.0, daily_sleep_hours: 8.0 },
          { day: Date.new(2024, 1, 14), daily_wake_hours: 17.0, daily_sleep_hours: 7.0 },
          { day: Date.new(2024, 1, 15), daily_wake_hours: 15.0, daily_sleep_hours: 9.0 }
        ]
      end

      it '今日(1/15)のデータを除外して計算する' do
        aggregator = SleepRecordAggregator.new([])
        result = aggregator.average_daily_hours(daily_records, exclude_today: true)

        expect(result[:wake]).to eq(16.5)
        expect(result[:sleep]).to eq(7.5)
      end
    end

    context '今日のデータを含める場合' do
      let(:daily_records) do
        [
          { day: Date.new(2024, 1, 13), daily_wake_hours: 16.0, daily_sleep_hours: 8.0 },
          { day: Date.new(2024, 1, 14), daily_wake_hours: 17.0, daily_sleep_hours: 7.0 },
          { day: Date.new(2024, 1, 15), daily_wake_hours: 15.0, daily_sleep_hours: 9.0 }
        ]
      end

      it '今日のデータを含めて計算する' do
        aggregator = SleepRecordAggregator.new([])
        result = aggregator.average_daily_hours(daily_records, exclude_today: false)

        expect(result[:wake]).to eq(16.0)
        expect(result[:sleep]).to eq(8.0)
      end
    end

    context 'データが空の場合' do
      it '0.0を返す' do
        aggregator = SleepRecordAggregator.new([])
        result = aggregator.average_daily_hours([], exclude_today: true)

        expect(result[:wake]).to eq(0.0)
        expect(result[:sleep]).to eq(0.0)
      end
    end

    context '起床データのみの場合' do
      let(:daily_records) do
        [
          { day: Date.new(2024, 1, 10), daily_wake_hours: 17.0, daily_sleep_hours: nil },
          { day: Date.new(2024, 1, 11), daily_wake_hours: 16.0, daily_sleep_hours: nil },
          { day: Date.new(2024, 1, 12), daily_wake_hours: 15.0, daily_sleep_hours: nil }
        ]
      end

      it '起床時間のみ平均を返し、睡眠時間は0.0を返す' do
        aggregator = SleepRecordAggregator.new([])
        result = aggregator.average_daily_hours(daily_records, exclude_today: false)

        expect(result[:wake]).to eq(16.0)
        expect(result[:sleep]).to eq(0.0)
      end
    end

    context '睡眠データのみの場合' do
      let(:daily_records) do
        [
          { day: Date.new(2024, 1, 10), daily_wake_hours: nil, daily_sleep_hours: 8.0 },
          { day: Date.new(2024, 1, 11), daily_wake_hours: nil, daily_sleep_hours: 7.0 },
          { day: Date.new(2024, 1, 12), daily_wake_hours: nil, daily_sleep_hours: 9.0 }
        ]
      end

      it '睡眠時間のみ平均を返し、起床時間は0.0を返す' do
        aggregator = SleepRecordAggregator.new([])
        result = aggregator.average_daily_hours(daily_records, exclude_today: false)

        expect(result[:wake]).to eq(0.0)
        expect(result[:sleep]).to eq(8.0)
      end
    end
  end

  describe '#average_time' do
    let(:user) { FactoryBot.create(:user) }

    context '起床時刻の平均' do
      it '複数の記録から平均起床時刻を計算する' do
        records = [
          FactoryBot.create(:sleep_record, user: user, wake_time: Time.zone.local(2024, 1, 10, 7, 0), bed_time: Time.zone.local(2024, 1, 10, 23, 0)),
          FactoryBot.create(:sleep_record, user: user, wake_time: Time.zone.local(2024, 1, 11, 6, 30), bed_time: Time.zone.local(2024, 1, 11, 22, 30)),
          FactoryBot.create(:sleep_record, user: user, wake_time: Time.zone.local(2024, 1, 12, 7, 30), bed_time: Time.zone.local(2024, 1, 12, 23, 30))
        ]

        aggregator = SleepRecordAggregator.new(records)
        result = aggregator.average_time(:wake_time)

        expect(result).to eq('07:00')
      end
    end

    context '就寝時刻の平均' do
      it '深夜0-6時の就寝時刻を正しく扱う' do
        records = [
          FactoryBot.create(:sleep_record, user: user, wake_time: Time.zone.local(2024, 1, 10, 7, 0), bed_time: Time.zone.local(2024, 1, 10, 23, 0)),
          FactoryBot.create(:sleep_record, user: user, wake_time: Time.zone.local(2024, 1, 11, 7, 0), bed_time: Time.zone.local(2024, 1, 12, 0, 0)),
          FactoryBot.create(:sleep_record, user: user, wake_time: Time.zone.local(2024, 1, 12, 7, 0), bed_time: Time.zone.local(2024, 1, 13, 1, 0))
        ]

        aggregator = SleepRecordAggregator.new(records)
        result = aggregator.average_time(:bed_time)

        expect(result).to eq('00:00')
      end
    end

    context '記録が空の場合' do
      it 'nilを返す' do
        aggregator = SleepRecordAggregator.new([])
        result = aggregator.average_time(:wake_time)

        expect(result).to be_nil
      end
    end
  end
end
