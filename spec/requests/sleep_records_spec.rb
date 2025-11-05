require 'rails_helper'

RSpec.describe "SleepRecords", type: :request do
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  describe "POST /sleep_records" do
    it "起床記録が作成できる" do
      expect {
        post sleep_records_path
      }.to change { SleepRecord.count }.by(1)
      expect(response).to redirect_to(authenticated_root_path)
    end
  end

  describe "PATCH /sleep_records/:id" do
    context "就寝ボタンからの更新" do
      it "就寝記録が更新できる" do
        record = FactoryBot.create(:sleep_record, :unbedded, user: user)
        patch sleep_record_path(record), params: { record_type: "bed_time" }
        record.reload
        expect(record.bed_time).not_to be_nil
        expect(response).to redirect_to(authenticated_root_path)
      end
    end

    context "編集フォームからの更新" do
      it "起床・就寝時刻を編集できる" do
        wake_time = 2.days.ago.change(hour: 6, min: 0)
        bed_time = wake_time + 1.hour
        record = FactoryBot.create(:sleep_record, user: user, wake_time: wake_time, bed_time: bed_time)
        
        new_wake_time = 3.days.ago.change(hour: 7, min: 0)
        new_bed_time = new_wake_time + 2.hours

        patch sleep_record_path(record), params: {
          sleep_record: {
            wake_time: new_wake_time.strftime("%Y-%m-%dT%H:%M"),
            bed_time: new_bed_time.strftime("%Y-%m-%dT%H:%M")
          }
        }

        record.reload
        expect(record.wake_time).to be_within(1.minute).of(new_wake_time)
        expect(record.bed_time).to be_within(1.minute).of(new_bed_time)
        expect(response).to redirect_to(authenticated_root_path)
      end

      it "未来の時刻は保存できない" do
        wake_time = 2.days.ago.change(hour: 6, min: 0)
        bed_time = wake_time + 1.hour
        record = FactoryBot.create(:sleep_record, user: user, wake_time: wake_time, bed_time: bed_time)
        
        future_time = 1.day.from_now

        patch sleep_record_path(record), params: {
          sleep_record: {
            wake_time: future_time.strftime("%Y-%m-%dT%H:%M"),
            bed_time: record.bed_time.strftime("%Y-%m-%dT%H:%M")
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /sleep_records/new" do
    it "新規作成画面が表示できる" do
      get new_sleep_record_path
      expect(response).to have_http_status(:success)
    end

    it "日付パラメータがあれば初期値として設定される" do
      date = "2025-11-01"
      get new_sleep_record_path(date: date)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("2025-11-01T06:00")
      expect(response.body).to include("2025-11-01T22:00")
    end
  end

  describe "GET /sleep_records/:id/edit" do
    it "編集画面が表示できる" do
      wake_time = 2.days.ago.change(hour: 6, min: 0)
      bed_time = wake_time + 1.hour
      record = FactoryBot.create(:sleep_record, user: user, wake_time: wake_time, bed_time: bed_time)
      
      get edit_sleep_record_path(record)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /sleep_records (フォームから)" do
    it "過去の記録を新規作成できる" do
      past_wake_time = 2.days.ago.change(hour: 6, min: 0)
      past_bed_time = past_wake_time + 1.hour

      expect {
        post sleep_records_path, params: {
          sleep_record: {
            wake_time: past_wake_time.strftime("%Y-%m-%dT%H:%M"),
            bed_time: past_bed_time.strftime("%Y-%m-%dT%H:%M")
          }
        }
      }.to change { SleepRecord.count }.by(1)

      created_record = SleepRecord.last
      expect(created_record.wake_time).to be_within(1.minute).of(past_wake_time)
      expect(created_record.bed_time).to be_within(1.minute).of(past_bed_time)
      expect(response).to redirect_to(authenticated_root_path)
    end

    it "未来の時刻は保存できない" do
      future_time = 1.day.from_now

      expect {
        post sleep_records_path, params: {
          sleep_record: {
            wake_time: future_time.strftime("%Y-%m-%dT%H:%M"),
            bed_time: (future_time + 1.hour).strftime("%Y-%m-%dT%H:%M")
          }
        }
      }.not_to change { SleepRecord.count }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
