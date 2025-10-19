require 'rails_helper'

RSpec.describe "Users", type: :system do
  scenario "ユーザー登録できること" do
    visit new_user_registration_path
    fill_in I18n.t('activerecord.attributes.user.name'), with: "admin"
    fill_in I18n.t('activerecord.attributes.user.email'), with: "test@example.com"
    fill_in I18n.t('activerecord.attributes.user.password'), with: "password"
    fill_in I18n.t('activerecord.attributes.user.password_confirmation'), with: "password"
    click_button I18n.t('devise.shared.links.sign_up')

    expect(page).to have_content(I18n.t('devise.registrations.signed_up'))
  end

  feature "sign in" do
    given(:user) { FactoryBot.create(:user) }

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

  describe "Profile" do
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

  describe "Profile Edit - Access control" do
    scenario "未ログインで編集ページにアクセスするとログイン画面へリダイレクト" do
      visit edit_profile_path
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content(I18n.t('devise.failure.unauthenticated'))
    end
  end

  describe "Profile Edit" do
    let(:user) { FactoryBot.create(:user) }

    before do
      visit new_user_session_path
      fill_in I18n.t('activerecord.attributes.user.email'), with: user.email
      fill_in I18n.t('activerecord.attributes.user.password'), with: user.password
      click_button I18n.t('devise.shared.links.sign_in')
      visit edit_profile_path
    end

    context "ログイン済みユーザー" do
      scenario "編集フォームと現在のプロフィール情報が表示される" do
        expect(page).to have_content(I18n.t('profiles.edit.page_title'))

        expect(page).to have_field(I18n.t('profiles.edit.name_label'), with: user.name)
      end

      scenario "有効な名前を入力して保存すると成功メッセージと新しい名前が表示される" do
        fill_in I18n.t('profiles.edit.name_label'), with: "新しい名前"
        choose 'boy-1', allow_label_click: true # ← アバターも選択(バリデーション通過のため)
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
end
