require 'rails_helper'

RSpec.describe "プロフィール表示", type: :system do
  let(:user) { FactoryBot.create(:user) }

  before do
    visit new_user_session_path
    fill_in I18n.t('activerecord.attributes.user.email'), with: user.email
    fill_in I18n.t('activerecord.attributes.user.password'), with: user.password
    click_button I18n.t('devise.shared.links.sign_in')
    user.update(avatar: nil)
    visit profile_path
  end

  scenario "自分のプロフィールページが表示できる" do
    expect(page).to have_content(user.name)
  end

  scenario "メールアドレスが表示されないこと" do
    expect(page).not_to have_content(user.email)
  end

  scenario "ページタイトルがI18nで表示される" do
    expect(page).to have_content(I18n.t('profiles.show.page_title'))
  end
end
