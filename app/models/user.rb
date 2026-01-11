class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  has_many :sleep_records, dependent: :destroy

  validates :name, presence: true, length: { maximum: 20 }

  # 新規登録時は選択しないため更新時のみバリデーションを行う
  validates :avatar, presence: true, on: :update

  def avatar_filename
    return "default.png" if avatar.blank?
    avatar.to_s.include?(".") ? avatar : "#{avatar}.png"
  end

  def avatar=(value)
    normalized = if value.present? && !value.to_s.include?(".")
      "#{value}.png"
    else
      value
    end
    super(normalized)
  end
end
