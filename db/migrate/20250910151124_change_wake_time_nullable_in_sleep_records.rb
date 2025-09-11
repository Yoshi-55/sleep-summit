class ChangeWakeTimeNullableInSleepRecords < ActiveRecord::Migration[7.2]
  def change
    change_column :sleep_records, :wake_time, :datetime, null: true
  end
end
