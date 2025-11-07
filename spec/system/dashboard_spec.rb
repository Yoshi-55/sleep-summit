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

  it "ページタイトルがI18nで表示されること" do
    expect(page).to have_content(I18n.t('dashboard.index.page_title'))
  end

  it "グラフが表示されること" do
    expect(page).to have_selector("#sleep-chart")
  end

  it "１週間の記録が表示されること" do
    expect(page).to have_content(I18n.t('dashboard.index.this_week_records'))
  end

  it "起床記録ボタンが表示されていて押せること" do
    expect(page).to have_button(I18n.t('dashboard.index.wake_record'), disabled: false)
    find('button[data-test="mobile-wake-button"], button[data-test="desktop-wake-button"]', match: :first).click
    expect(page).to have_content(I18n.t('dashboard.index.wake_record'))
  end

  it "未就寝レコードがある場合は就寝記録ボタンが有効になること" do
    FactoryBot.create(:sleep_record, :unbedded, user: user)
    visit dashboard_path
    expect(page).to have_button(I18n.t('dashboard.index.bed_record'), disabled: false)
    find('button[data-test="mobile-bed-button"], button[data-test="desktop-bed-button"]', match: :first).click
    expect(page).to have_content(I18n.t('dashboard.index.bed_record'))
  end

  it "起床記録後に就寝記録ボタンが有効になること" do
    find('button[data-test="mobile-wake-button"], button[data-test="desktop-wake-button"]', match: :first).click
    expect(page).to have_button(I18n.t('dashboard.index.bed_record'), disabled: false)
    find('button[data-test="mobile-bed-button"], button[data-test="desktop-bed-button"]', match: :first).click
    expect(page).to have_content(I18n.t('dashboard.index.bed_record'))
  end
end
