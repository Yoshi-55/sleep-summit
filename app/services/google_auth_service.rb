require "google/apis/calendar_v3"
require "googleauth"

class GoogleAuthService
  def initialize(user)
    @user = user
  end

  # Google Calendar APIクライアント取得
  def calendar_client
    return nil unless @user.google_authenticated?
    return nil unless ENV["GOOGLE_CLIENT_ID"].present? && ENV["GOOGLE_CLIENT_SECRET"].present?

    client = Google::Apis::CalendarV3::CalendarService.new
    client.authorization = authorization
    client
  end

  # トークンを強制的にリフレッシュ
  def refresh_token!
    auth = authorization
    auth.fetch_access_token!
    update_user_token(auth)
  end

  private

  def authorization
    return nil unless ENV["GOOGLE_CLIENT_ID"].present? && ENV["GOOGLE_CLIENT_SECRET"].present?

    auth = Google::Auth::UserRefreshCredentials.new(
      client_id: ENV["GOOGLE_CLIENT_ID"],
      client_secret: ENV["GOOGLE_CLIENT_SECRET"],
      scope: [ "https://www.googleapis.com/auth/calendar" ],
      access_token: @user.google_token,
      refresh_token: @user.google_refresh_token,
      expires_at: @user.google_token_expires_at&.to_i
    )

    # トークンが期限切れの場合、自動的にリフレッシュ
    if @user.google_token_expired? && @user.google_refresh_token.present?
      auth.fetch_access_token!
      update_user_token(auth)
    end

    auth
  end

  def update_user_token(auth)
    @user.update_columns(
      google_token: auth.access_token,
      google_token_expires_at: Time.at(auth.expires_at),
      updated_at: Time.current
    )
  end
end
