require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  describe "GET /profile" do
    it "自分のプロフィールページが表示できる" do
      sign_in user
      get profile_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(user.name)
    end

    it "メールアドレスが表示されないこと" do
      get profile_path
      expect(response.body).not_to include(user.email)
    end

    it "未ログイン時はログイン画面へリダイレクトされる" do
      sign_out user
      get profile_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
