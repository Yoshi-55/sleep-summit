class RemoveUnusedColumnsFromUsersAndSleepRecords < ActiveRecord::Migration[7.2]
  def change
    # Remove unused note column from sleep_records
    remove_column :sleep_records, :note, :text

    # Remove unused Google OAuth columns from users
    remove_column :users, :provider, :string
    remove_column :users, :uid, :string
    remove_column :users, :google_token, :string
    remove_column :users, :google_refresh_token, :string
    remove_column :users, :google_token_expires_at, :datetime
  end
end
