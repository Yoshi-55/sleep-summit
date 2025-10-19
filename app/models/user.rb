class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :sleep_records, dependent: :destroy

  validates :name, presence: true

  # 新規登録時は選択しないため更新時のみバリデーションを行う
  validates :avatar, presence: true, on: :update
end
