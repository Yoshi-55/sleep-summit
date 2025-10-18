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

  # ------------------------------------------------

  describe "Profile" do
    let(:user) { FactoryBot.create(:user) }

    before do
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

  # ------------------------------------------------

  describe "Profile Edit" do
    let(:user) { FactoryBot.create(:user) }

    before do
      visit new_user_session_path
      fill_in I18n.t('activerecord.attributes.user.email'), with: user.email
      fill_in I18n.t('activerecord.attributes.user.password'), with: user.password
      click_button I18n.t('devise.shared.links.sign_in')
      visit edit_profile_path
    end

    it "プロフィール編集ページが表示できること" do
      expect(page).to have_content(I18n.t('profiles.edit.page_title'))
    end

    it "名前が空だとエラーになること" do
      fill_in I18n.t('activerecord.attributes.user.name'), with: ""
      click_button I18n.t('profiles.edit.submit')
      expect(page).to have_content(I18n.t('errors.messages.blank'))
    end

    it "名前を変更して保存できること" do
      fill_in I18n.t('activerecord.attributes.user.name'), with: "newname"
      click_button I18n.t('profiles.edit.submit')
      expect(page).to have_content(I18n.t('profiles.update.success'))
      expect(page).to have_content("newname")
    end

    it "プロフィールアイコンを変更して保存できること" do
      attach_file I18n.t('activerecord.attributes.user.avatar'), Rails.root.join('spec/fixtures/files/sample_avatar.png')
      click_button I18n.t('profiles.edit.submit')
      expect(page).to have_content(I18n.t('profiles.update.success'))
      expect(page).to have_selector("img[src$='sample_avatar.png']")
    end
  end
end
