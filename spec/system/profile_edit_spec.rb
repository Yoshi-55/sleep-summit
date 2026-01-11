require 'rails_helper'

RSpec.describe "プロフィール編集", type: :system do
  let(:user) { FactoryBot.create(:user) }

  context "未ログイン時" do
    it "編集ページにアクセスするとログイン画面へリダイレクト" do
      visit edit_profile_path
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content(I18n.t('devise.failure.unauthenticated'))
    end
  end

  context "ログイン済みで編集ページにアクセスした場合" do
    before do
      visit new_user_session_path
      fill_in I18n.t('activerecord.attributes.user.email'), with: user.email
      fill_in I18n.t('activerecord.attributes.user.password'), with: user.password
      click_button I18n.t('devise.shared.links.sign_in')
      visit edit_profile_path
    end

    it "編集フォームと現在のプロフィール情報が表示される" do
      expect(page).to have_content(I18n.t('profiles.edit.page_title'))
      expect(page).to have_field(I18n.t('profiles.edit.name_label'), with: user.name)
    end

    it "名前とアバターを変更できる" do
      fill_in I18n.t('profiles.edit.name_label'), with: "新しい名前"
      choose 'boy-1', allow_label_click: true
      click_button I18n.t('profiles.edit.submit')

      expect(page).to have_content(I18n.t('profiles.update.success'))
      expect(page).to have_content("新しい名前")
      expect(page).to have_selector("img[alt='#{I18n.t('profiles.edit.avatar_label')}'][src*='boy-1']")
    end

    it "バリデーションエラーが正しく表示される" do
      # アバター未選択
      click_button I18n.t('profiles.edit.submit')
      expect(page).to have_content(I18n.t('profiles.update.avatar_error'))

      # 名前が長すぎる
      long_name = 'あ' * 21
      fill_in I18n.t('activerecord.attributes.user.name'), with: long_name
      choose 'boy-1', allow_label_click: true
      click_button I18n.t('profiles.edit.submit')
      expect(page).to have_content(I18n.t('profiles.update.name_length_error', count: 20))
    end
  end
end
