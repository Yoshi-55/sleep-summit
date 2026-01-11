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

  it "プロフィールページが正常に表示される" do
    expect(page).to have_content(user.name)
    expect(page).not_to have_content(user.email)
  end
end
