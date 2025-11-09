class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    auth = request.env["omniauth.auth"]

    if user_signed_in?
      # 既存のログインユーザーにGoogle認証を紐付ける
      Rails.logger.info "=== Google OAuth Callback ==="
      Rails.logger.info "Current User ID: #{current_user.id}"
      Rails.logger.info "Auth Provider: #{auth.provider}"
      Rails.logger.info "Auth UID: #{auth.uid}"
      Rails.logger.info "Auth Token: #{auth.credentials.token}"

      # バリデーションをスキップして直接更新
      current_user.update_columns(
        provider: auth.provider,
        uid: auth.uid
      )
      Rails.logger.info "Provider and UID updated"

      current_user.update_google_credentials(auth)
      Rails.logger.info "After update_google_credentials - Token present: #{current_user.google_token.present?}"

      redirect_to google_calendars_path, notice: "Googleカレンダーと連携しました"
    else
      # 未ログインの場合は、既存のGoogle認証ユーザーを探すか新規作成
      @user = User.from_omniauth(auth)

      if @user.persisted?
        @user.update_google_credentials(auth)
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
      else
        session["devise.google_data"] = auth.except(:extra)
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
      end
    end
  end

  def failure
    redirect_to root_path, alert: "Google認証に失敗しました。もう一度お試しください。"
  end
end
