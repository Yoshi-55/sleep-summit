require 'rails_helper'

RSpec.describe "Users", type: :system do
  it "ユーザー登録できること" do
    visit new_user_registration_path
    fill_in "Name", with: "admin"
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"
    click_button "Sign up"

    expect(page).to have_content("Welcome! You have signed up successfully.")
  end

  it "ログインできること" do
    FactoryBot.create(:user)
    visit new_user_session_path
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password"
    click_button "Log in"

    expect(page).to have_content("Signed in successfully.")
  end
end
