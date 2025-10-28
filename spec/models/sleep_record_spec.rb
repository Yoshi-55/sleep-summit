require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  let(:user) { FactoryBot.create(:user) }

  describe "バリデーション" do
    context "wake_timeがある場合" do
      it "有効である" do
        record = FactoryBot.build(:sleep_record)
        expect(record).to be_valid
      end
    end

    context "wake_timeがない場合" do
      it "無効である" do
        record = FactoryBot.build(:sleep_record, wake_time: nil)
        expect(record).not_to be_valid
        expect(record.errors[:wake_time]).not_to be_empty
      end
    end

    context "bed_timeとwake_timeの関係" do
      let(:wake_time) { Time.zone.local(2025, 1, 1, 7, 0, 0) }

      it "bed_timeがwake_timeより後（同日）は有効" do
        record = FactoryBot.build(:sleep_record, wake_time: wake_time, bed_time: wake_time + 1.hour)
        expect(record).to be_valid
      end

      it "bed_timeがwake_timeと同じは無効" do
        record = FactoryBot.build(:sleep_record, wake_time: wake_time, bed_time: wake_time)
        expect(record).not_to be_valid
        expect(record.errors[:bed_time]).not_to be_empty
      end

      it "bed_timeがwake_timeより前（同日）は無効" do
        record = FactoryBot.build(:sleep_record, wake_time: wake_time, bed_time: wake_time - 1.hour)
        expect(record).not_to be_valid
        expect(record.errors[:bed_time]).not_to be_empty
      end

      it "bed_timeがwake_timeより前だが日付をまたぐ（前日夜→翌朝）は有効" do
        bed_time = wake_time - 8.hours # 前日23:00
        record = FactoryBot.build(:sleep_record, wake_time: wake_time, bed_time: bed_time)
        expect(record).to be_valid
      end
    end
  end

  describe "Userとの関連" do
    it "userと関連していること" do
      record = FactoryBot.build(:sleep_record, user: user)
      expect(record.user).to eq user
    end
  end
end
