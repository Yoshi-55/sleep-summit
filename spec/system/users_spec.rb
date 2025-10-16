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
end
