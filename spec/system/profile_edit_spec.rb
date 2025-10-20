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

    context "有効な入力の場合" do
      it "有効な名前を入力して保存すると成功メッセージと新しい名前が表示される" do
        fill_in I18n.t('profiles.edit.name_label'), with: "新しい名前"
        choose 'boy-1', allow_label_click: true
        click_button I18n.t('profiles.edit.submit')

        expect(page).to have_content(I18n.t('profiles.update.success'))
        expect(page).to have_content("新しい名前")
      end

      it "プリセット画像(boy-1)を選択して保存すると成功メッセージとプロフィールが更新される" do
        choose 'boy-1', allow_label_click: true
        click_button I18n.t('profiles.edit.submit')

        expect(page).to have_content(I18n.t('profiles.update.success'))
        expect(page).to have_selector("img[alt='#{I18n.t('profiles.edit.avatar_label')}'][src*='boy-1']")
      end

      it "ユーザー名を変更できる" do
        fill_in I18n.t('activerecord.attributes.user.name'), with: "新しい名前"
        choose 'boy-1', allow_label_click: true
        click_button I18n.t('profiles.edit.submit')
        expect(page).to have_content("新しい名前")
      end
    end

    context "無効な入力の場合" do
      it "プリセット未選択で保存するとエラーメッセージが表示され、更新されない" do
        click_button I18n.t('profiles.edit.submit')

        expect(page).to have_content(I18n.t('profiles.update.avatar_error'))
      end

      it "最大(20)文字数を超える名前は変更できない" do
        long_name = 'あ' * 21
        fill_in I18n.t('activerecord.attributes.user.name'), with: long_name
        choose 'boy-1', allow_label_click: true
        click_button I18n.t('profiles.edit.submit')
        expect(page).to have_content(I18n.t('profiles.update.name_length_error', count: 20))
      end

      it "空の名前は変更できない" do
        fill_in I18n.t('activerecord.attributes.user.name'), with: ""
        choose 'boy-1', allow_label_click: true
        click_button I18n.t('profiles.edit.submit')
        expect(page).to have_content(I18n.t('profiles.update.name_error'))
      end

      it "登録時のバリデーションと整合性が保たれる" do
        fill_in I18n.t('activerecord.attributes.user.name'), with: ""
        choose 'boy-1', allow_label_click: true
        click_button I18n.t('profiles.edit.submit')
        expect(page).to have_content(I18n.t('profiles.update.name_error'))

        long_name = 'あ' * 21
        fill_in I18n.t('activerecord.attributes.user.name'), with: long_name
        choose 'boy-1', allow_label_click: true
        click_button I18n.t('profiles.edit.submit')
        expect(page).to have_content(I18n.t('profiles.update.name_length_error', count: 20))
      end
    end
  end
end
