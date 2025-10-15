require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーションチェック" do
    context "有効な値の場合" do
      it "バリデーションを通過すること" do
        user = FactoryBot.build(:user)
        expect(user).to be_valid
        expect(user.errors).to be_empty
      end
    end

    context "メールアドレスがない場合" do
      it "バリデーションに失敗すること" do
        user = FactoryBot.build(:user, email: nil)
        expect(user).not_to be_valid
        expect(user.errors[:email]).not_to be_empty
      end
    end

    context "パスワードがない場合" do
      it "バリデーションに失敗すること" do
        user = FactoryBot.build(:user, password: nil)
        expect(user).not_to be_valid
        expect(user.errors[:password]).not_to be_empty
      end
    end

    context "メールアドレスが重複している場合" do
      it "バリデーションに失敗すること" do
        FactoryBot.create(:user)
        user = FactoryBot.build(:user)
        expect(user).not_to be_valid
        expect(user.errors[:email]).not_to be_empty
      end
    end

    context "パスワードが短すぎる場合" do
      it "バリデーションに失敗すること" do
        user = FactoryBot.build(:user, password: "123")
        expect(user).not_to be_valid
        expect(user.errors[:password]).not_to be_empty
      end
    end
  end

  describe "sleep_recordsとの関連" do
    it "ユーザー削除時にsleep_recordsも削除されること" do
      user = FactoryBot.create(:user)
      FactoryBot.create(:sleep_record, user: user)
      expect { user.destroy }.to change { SleepRecord.count }.by(-1)
    end
  end
end
