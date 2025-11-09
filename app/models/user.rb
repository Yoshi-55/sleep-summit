class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :sleep_records, dependent: :destroy

  validates :name, presence: true, length: { maximum: 20 }

  # 新規登録時は選択しないため更新時のみバリデーションを行う
  validates :avatar, presence: true, on: :update

  # Google認証済みかどうかを判定
  def google_authenticated?
    return false unless ENV["GOOGLE_CLIENT_ID"].present? && ENV["GOOGLE_CLIENT_SECRET"].present?
    provider.present? && uid.present? && google_token.present?
  end

  # Googleトークンが有効期限切れかどうかを判定
  def google_token_expired?
    return true if google_token_expires_at.blank?
    google_token_expires_at < Time.current
  end

  # OmniAuthのコールバックデータからユーザーを検索または作成
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name || auth.info.email.split("@").first
    end
  end

  # Google認証情報を更新
  def update_google_credentials(auth)
    update_columns(
      google_token: auth.credentials.token,
      google_refresh_token: auth.credentials.refresh_token || google_refresh_token,
      google_token_expires_at: Time.at(auth.credentials.expires_at),
      updated_at: Time.current
    )
  end

  # Google連携を解除
  def disconnect_google
    update_columns(
      provider: nil,
      uid: nil,
      google_token: nil,
      google_refresh_token: nil,
      google_token_expires_at: nil,
      updated_at: Time.current
    )
  end
end
