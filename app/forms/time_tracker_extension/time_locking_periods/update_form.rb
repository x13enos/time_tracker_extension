module TimeTrackerExtension
  module TimeLockingPeriods

    class UpdateForm < BaseForm
      attr_accessor :approved, :period, :dates_of_invalid_time_records
      validate :has_consistent_data?, if: :approved
      validate :does_not_contain_running_tasks?, if: :approved

  
      def initialize(attributes, period)
        @period = period
        @dates_of_invalid_time_records = []
        super(attributes)
      end
  
      def persist!
        update_period
        update_telegram_message
        send_reports
      end
  
      private

      def update_period
        period.update(as_json.slice("approved"))
      end
  
      def has_consistent_data?
        inconsistent_entries = period.tasks.where("coalesce(description, '') = '' OR project_id IS NULL")
        if inconsistent_entries.count > 0
          @dates_of_invalid_time_records = inconsistent_entries.map(&:assigned_date).uniq
          errors.add(:base, I18n.t("time_locking_periods.has_inconsistent_data"))
        end
      end
  
      def does_not_contain_running_tasks?
        if period.tasks.where("time_records.time_start IS NOT NULL").any?
          errors.add(:base, I18n.t("time_locking_periods.has_active_task"))
        end
      end
  
      def update_telegram_message
        return unless period.telegram_message_id
  
        text = I18n.t(
          'telegram.period_was_succesfully_approved',
          workspace: period.workspace.name,
          from: period.beginning_of_period,
          to: period.end_of_period
        )
        Telegram.bot.edit_message_text(chat_id: period.user.telegram_id, text: text, message_id: period.telegram_message_id)
        period.update(telegram_message_id: nil)
      end

      def send_reports
        TimeTrackerExtension::SendPeriodReportsJob.perform_later(period)
      end
    end
    
  end
end
