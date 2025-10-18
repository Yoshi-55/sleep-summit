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
    it "就寝記録が更新できる" do
      record = FactoryBot.create(:sleep_record, :unbedded, user: user)
      patch sleep_record_path(record)
      record.reload
      expect(record.bed_time).not_to be_nil
      expect(response).to redirect_to(authenticated_root_path)
    end
  end
end
