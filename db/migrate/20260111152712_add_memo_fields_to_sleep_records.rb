class AddMemoFieldsToSleepRecords < ActiveRecord::Migration[7.2]
  def change
    add_column :sleep_records, :mood, :integer
    add_column :sleep_records, :condition, :integer
    add_column :sleep_records, :notes, :text
  end
end
