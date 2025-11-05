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

    context "bed_timeがwake_timeより前の場合" do
      it "無効である" do
        past_time = 1.day.ago
        record = FactoryBot.build(:sleep_record, wake_time: past_time, bed_time: past_time - 1.hour)
        expect(record).not_to be_valid
        expect(record.errors[:bed_time]).not_to be_empty
      end
    end

    context "bed_timeがwake_timeより後の場合" do
      it "有効である" do
        past_time = 1.day.ago
        record = FactoryBot.build(:sleep_record, wake_time: past_time, bed_time: past_time + 1.hour)
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
