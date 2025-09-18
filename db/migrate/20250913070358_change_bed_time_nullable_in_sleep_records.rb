class ChangeBedTimeNullableInSleepRecords < ActiveRecord::Migration[7.2]
  def change
    change_column :sleep_records, :bed_time, :datetime, null: true
  end
end
