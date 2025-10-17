require 'rails_helper'

RSpec.describe "Dashboard", type: :system do
  let(:user) { FactoryBot.create(:user, email: "test@example.com", password: "password", name: "テストユーザー") }

  before do
    SleepRecord.where(user: user).delete_all
    visit new_user_session_path
    fill_in I18n.t('activerecord.attributes.user.email'), with: user.email
    fill_in I18n.t('activerecord.attributes.user.password'), with: user.password
    click_button I18n.t('devise.shared.links.sign_in')
    expect(page).to have_content(I18n.t('dashboard.index.page_title'))
    visit dashboard_path
  end

  it "起床記録ボタンが表示されていて押せること" do
    expect(page).to have_button(I18n.t('dashboard.index.wake_record'), disabled: false)
    click_button I18n.t('dashboard.index.wake_record')
    expect(page).to have_content(I18n.t('dashboard.index.wake_record'))
  end

  it "未就寝レコードがある場合は就寝記録ボタンが有効になること" do
    FactoryBot.create(:sleep_record, :unbedded, user: user)
    visit dashboard_path
    expect(page).to have_button(I18n.t('dashboard.index.bed_record'), disabled: false)
    click_button I18n.t('dashboard.index.bed_record')
    expect(page).to have_content(I18n.t('dashboard.index.bed_record'))
  end

  it "起床記録後に就寝記録ボタンが有効になること" do
    click_button I18n.t('dashboard.index.wake_record')
    expect(page).to have_button(I18n.t('dashboard.index.bed_record'), disabled: false)
    click_button I18n.t('dashboard.index.bed_record')
    expect(page).to have_content(I18n.t('dashboard.index.bed_record'))
  end
end
