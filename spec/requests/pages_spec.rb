require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /terms" do
    it "利用規約ページが正常に表示されること" do
      get "/terms"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /privacy" do
    it "プライバシーポリシーページが正常に表示されること" do
      get "/privacy"
      expect(response).to have_http_status(:success)
    end
  end
end
