class RemoveUnusedMemoFieldsFromSleepRecords < ActiveRecord::Migration[7.2]
  def change
    remove_column :sleep_records, :condition, :integer
    remove_column :sleep_records, :notes, :text
  end
end
