class CreateTimeLockingPeriods < ActiveRecord::Migration[5.2]
  def change
    create_table :time_tracker_extension_time_locking_periods do |t|
      t.integer :workspace_id
      t.integer :user_id
      t.date    :beginning_of_period
      t.date    :end_of_period
      t.boolean :approved, default: false

      t.index [:workspace_id, :user_id], :name => 'locking_period_workspace_and_user_index'
      t.timestamps
    end
  end
end
