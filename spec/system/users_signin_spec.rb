require 'rails_helper'

RSpec.describe "ユーザーログイン", type: :system do
  let(:user) { FactoryBot.create(:user) }

  scenario "ログインできること" do
    visit new_user_session_path
    fill_in I18n.t('activerecord.attributes.user.email'), with: user.email
    fill_in I18n.t('activerecord.attributes.user.password'), with: user.password
    click_button I18n.t('devise.shared.links.sign_in')

    expect(page).to have_content(I18n.t('devise.sessions.signed_in'))

    visit profile_path
    expect(page).to have_current_path(profile_path)
    expect(page).to have_content(I18n.t('profiles.show.page_title'))
  end
end
