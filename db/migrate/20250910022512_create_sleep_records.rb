class CreateSleepRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :sleep_records do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :bed_time, null: false
      t.datetime :wake_time, null: false
      t.text :note

      t.timestamps
    end
  end
end
