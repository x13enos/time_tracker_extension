class CreateTimeTrackerExtensionTimeLockingRules < ActiveRecord::Migration[5.2]
  def change
    create_table :time_tracker_extension_time_locking_rules do |t|
      t.integer :workspace_id
      t.integer :period

      t.timestamps
    end
  end
end
