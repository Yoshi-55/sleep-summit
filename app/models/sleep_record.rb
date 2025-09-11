class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :bed_time, presence: true
  validate :wake_time_after_bed_time

  validates :note, length: { maximum: 100 }, allow_blank: true

  private

  def wake_time_after_bed_time
    return if bed_time.blank? || wake_time.blank?
    if wake_time <= bed_time
      errors.add(:wake_time, "無効な入力です。起床時間は就寝時間より後に設定してください。")
    end
  end
end
