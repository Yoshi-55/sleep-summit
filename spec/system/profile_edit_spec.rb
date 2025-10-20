require 'rails_helper'

RSpec.describe "プロフィール編集", type: :system do
  let(:user) { FactoryBot.create(:user) }

  describe "アクセス制御" do
    scenario "未ログインで編集ページにアクセスするとログイン画面へリダイレクト" do
      visit edit_profile_path
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content(I18n.t('devise.failure.unauthenticated'))
    end
  end

  describe "編集フォーム" do
    before do
      visit new_user_session_path
      fill_in I18n.t('activerecord.attributes.user.email'), with: user.email
      fill_in I18n.t('activerecord.attributes.user.password'), with: user.password
      click_button I18n.t('devise.shared.links.sign_in')
      visit edit_profile_path
    end

    scenario "編集フォームと現在のプロフィール情報が表示される" do
      expect(page).to have_content(I18n.t('profiles.edit.page_title'))
      expect(page).to have_field(I18n.t('profiles.edit.name_label'), with: user.name)
    end

    scenario "有効な名前を入力して保存すると成功メッセージと新しい名前が表示される" do
      fill_in I18n.t('profiles.edit.name_label'), with: "新しい名前"
      choose 'boy-1', allow_label_click: true
      click_button I18n.t('profiles.edit.submit')

      expect(page).to have_content(I18n.t('profiles.update.success'))
      expect(page).to have_content("新しい名前")
    end

    scenario "名前を空欄で保存するとエラーメッセージが表示される" do
      fill_in I18n.t('profiles.edit.name_label'), with: ""
      click_button I18n.t('profiles.edit.submit')

      expect(page).to have_content(I18n.t('profiles.update.error'))
    end

    scenario "プリセット画像(boy-1)を選択して保存すると成功メッセージとプロフィールが更新される" do
      choose 'boy-1', allow_label_click: true
      click_button I18n.t('profiles.edit.submit')

      expect(page).to have_content(I18n.t('profiles.update.success'))
      expect(page).to have_selector("img[alt='#{I18n.t('profiles.edit.avatar_label')}'][src*='boy-1']")
    end

    scenario "プリセット未選択で保存するとエラーメッセージが表示され、更新されない" do
      click_button I18n.t('profiles.edit.submit')

      expect(page).to have_content(I18n.t('profiles.update.error'))
    end
  end
end
