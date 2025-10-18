require 'rails_helper'

RSpec.describe "Users", type: :system do
  it "ユーザー登録できること" do
    visit new_user_registration_path
    fill_in I18n.t('activerecord.attributes.user.name'), with: "admin"
    fill_in I18n.t('activerecord.attributes.user.email'), with: "test@example.com"
    fill_in I18n.t('activerecord.attributes.user.password'), with: "password"
    fill_in I18n.t('activerecord.attributes.user.password_confirmation'), with: "password"
    click_button I18n.t('devise.shared.links.sign_up')

    expect(page).to have_content(I18n.t('devise.registrations.signed_up'))
  end

  it "ログインできること" do
    FactoryBot.create(:user)
    visit new_user_session_path
    fill_in I18n.t('activerecord.attributes.user.email'), with: "test@example.com"
    fill_in I18n.t('activerecord.attributes.user.password'), with: "password"
    click_button I18n.t('devise.shared.links.sign_in')

    expect(page).to have_content(I18n.t('devise.sessions.signed_in'))
  end

  # ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

  describe "Profile" do
    let(:user) { FactoryBot.create(:user, email: "test@example.com", password: "password", name: "admin") }

    before do
      driven_by(:rack_test)
      visit new_user_session_path
      fill_in I18n.t('activerecord.attributes.user.email'), with: user.email
      fill_in I18n.t('activerecord.attributes.user.password'), with: user.password
      click_button I18n.t('devise.shared.links.sign_in')
      visit profile_path
    end

    it "自分のプロフィールページが表示できる" do
      expect(page).to have_content(user.name)
    end

    it "メールアドレスが表示されないこと" do
      expect(page).not_to have_content(user.email)
    end

    it "ページタイトルがI18nで表示される" do
      expect(page).to have_content(I18n.t('profiles.show.page_title'))
    end
  end
end
