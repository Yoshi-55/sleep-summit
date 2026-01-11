require 'rails_helper'

RSpec.describe "Dashboard", type: :system do
  let(:user) { FactoryBot.create(:user) }

  before do
    SleepRecord.where(user: user).delete_all
    visit new_user_session_path
    fill_in I18n.t('activerecord.attributes.user.email'), with: user.email
    fill_in I18n.t('activerecord.attributes.user.password'), with: user.password
    click_button I18n.t('devise.shared.links.sign_in')
    expect(page).to have_content(I18n.t('dashboard.index.page_title'))
    visit dashboard_path
  end

  it "起床→就寝の記録フローが正常に動作すること" do
    # 起床記録
    find('button[data-test="mobile-wake-button"], button[data-test="desktop-wake-button"]', match: :first).click
    expect(page).to have_content(I18n.t('dashboard.index.wake_record'))

    # 就寝記録ボタンが有効になる
    expect(page).to have_button(I18n.t('dashboard.index.bed_record'), disabled: false)

    # 就寝記録
    find('button[data-test="mobile-bed-button"], button[data-test="desktop-bed-button"]', match: :first).click
    expect(page).to have_content(I18n.t('dashboard.index.bed_record'))
  end
end
