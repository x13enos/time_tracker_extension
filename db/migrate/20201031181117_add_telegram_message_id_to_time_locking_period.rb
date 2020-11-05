class AddTelegramMessageIdToTimeLockingPeriod < ActiveRecord::Migration[6.0]
  def change
    add_column :time_tracker_extension_time_locking_periods, :telegram_message_id, :integer
  end
end
