require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーションチェック" do
    context "有効な値の場合" do
      it "バリデーションを通過すること" do
        user = User.new(email: "test@example.com", password: "password")
        expect(user).to be_valid
        expect(user.errors).to be_empty
      end
    end

    context "メールアドレスがない場合" do
      it "バリデーションに失敗すること" do
        user = User.new(email: nil, password: "password")
        expect(user).not_to be_valid
        expect(user.errors[:email]).not_to be_empty
      end
    end

    context "パスワードがない場合" do
      it "バリデーションに失敗すること" do
        user = User.new(email: "test@example.com", password: nil)
        expect(user).not_to be_valid
        expect(user.errors[:password]).not_to be_empty
      end
    end

    context "メールアドレスが重複している場合" do
      it "バリデーションに失敗すること" do
        User.create(email: "test@example.com", password: "password")
        user = User.new(email: "test@example.com", password: "password")
        expect(user).not_to be_valid
        expect(user.errors[:email]).not_to be_empty
      end
    end

    context "パスワードが短すぎる場合" do
      it "バリデーションに失敗すること" do
        user = User.new(email: "test@example.com", password: "123")
        expect(user).not_to be_valid
        expect(user.errors[:password]).not_to be_empty
      end
    end
  end

  describe "sleep_recordsとの関連" do
    it "ユーザー削除時にsleep_recordsも削除されること" do
      user = User.create(email: "test@example.com", password: "password")
      user.sleep_records.create(wake_time: Time.current, bed_time: Time.current + 8.hours)
      expect { user.destroy }.to change { SleepRecord.count }.by(-1)
    end
  end
end
