require 'rails_helper'

RSpec.describe "ユーザー新規登録", type: :system do
  scenario "ユーザー登録できること" do
    visit new_user_registration_path
    fill_in I18n.t('activerecord.attributes.user.name'), with: "admin"
    fill_in I18n.t('activerecord.attributes.user.email'), with: "test@example.com"
    fill_in I18n.t('activerecord.attributes.user.password'), with: "password"
    fill_in I18n.t('activerecord.attributes.user.password_confirmation'), with: "password"
    click_button I18n.t('devise.shared.links.sign_up')

    expect(page).to have_content(I18n.t('devise.registrations.signed_up'))
  end
end
