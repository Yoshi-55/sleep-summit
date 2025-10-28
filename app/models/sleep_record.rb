class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :wake_time, presence: true
  validate :bed_time_after_wake_time

  scope :unbedded, -> { where(bed_time: nil) }
  scope :with_wake_time, -> { where.not(wake_time: nil) }
  scope :finished, -> { where.not(bed_time: nil) }

  private

  def bed_time_after_wake_time
    return if wake_time.blank? || bed_time.blank?
    if bed_time == wake_time
      errors.add(:bed_time, "無効な入力です。就寝時刻は起床時刻より後に設定してください。")
      return
    end
    if bed_time < wake_time
      # 前日夜→翌朝のみ許容
      if bed_time.to_date == (wake_time.to_date - 1)
        nil
      else
        errors.add(:bed_time, "無効な入力です。就寝時刻は起床時刻より後に設定してください。")
      end
    end
  end
end
