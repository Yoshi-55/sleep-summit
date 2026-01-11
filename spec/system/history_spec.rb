require 'rails_helper'

RSpec.describe "History", type: :system do
  let(:user) { FactoryBot.create(:user) }

  before do
    SleepRecord.where(user: user).delete_all
    visit new_user_session_path
    fill_in I18n.t('activerecord.attributes.user.email'), with: user.email
    fill_in I18n.t('activerecord.attributes.user.password'), with: user.password
    click_button I18n.t('devise.shared.links.sign_in')
    expect(page).to have_content(I18n.t('history.index.page_title'))
    visit history_path
  end

  it "履歴ページが正常に表示される" do
    expect(page).to have_content(I18n.t('history.index.page_title'))
    expect(page).to have_selector("#sleep-chart")
  end
end
