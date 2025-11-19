class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :wake_time, presence: true
  validate :bed_time_after_wake_time
  validate :times_not_in_future
  validate :wake_time_after_previous_bed_time

  scope :unbedded, -> { where(bed_time: nil) }
  scope :with_wake_time, -> { where.not(wake_time: nil) }
  scope :finished, -> { where.not(bed_time: nil) }

  private

  def times_not_in_future
    if wake_time.present? && wake_time.to_date > Time.current.to_date
      errors.add(:wake_time, "未来の時刻は設定できません")
    end
    if bed_time.present? && bed_time.to_date > Time.current.to_date
      errors.add(:bed_time, "未来の時刻は設定できません")
    end
  end

  def bed_time_after_wake_time
    return if wake_time.blank? || bed_time.blank?
    if bed_time >= wake_time
      return
    elsif bed_time.to_date > wake_time.to_date
      return
    end
    errors.add(:bed_time, "無効な入力です。就寝時間は起床時間より後に設定してください。")
  end

  def wake_time_after_previous_bed_time
    return if wake_time.blank?
    # 前のレコードの就寝時刻より後に起床しているか確認
    previous_record = user.sleep_records.where.not(id: id).where("wake_time < ?", wake_time).order(wake_time: :desc).first
    if previous_record&.bed_time && wake_time < previous_record.bed_time
      errors.add(:wake_time, "前回の就寝時刻（#{previous_record.bed_time.strftime('%m月%d日 %H:%M')}）より後に設定してください")
    end
  end

end
