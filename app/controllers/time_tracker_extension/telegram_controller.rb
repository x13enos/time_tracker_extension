module TimeTrackerExtension
  class TelegramController < Telegram::Bot::UpdatesController
    include Telegram::Bot::UpdatesController::MessageContext
    include Telegram::Bot::UpdatesController::CallbackQueryContext

    use_session!
    self.session_store = :memory_store

    around_action :with_locale
    around_action :with_time_zone
    before_action :authorize_user, except: [:start!, :check_token!]

    def start!(*)
      save_context(:check_token!)
      respond_with :message, text: t('telegram.please_set_your_token')
    end

    def check_token!(text = nil, *)
      user = User.find_by(telegram_token: text)
      if user
        link_user_account(user)
      else
        save_context(:check_token!)
        respond_with :message, text: t('telegram.token_is_invalid')
      end
    end

    def approve_period_callback_query(period_id = nil, *)
      period = current_user.time_locking_periods.find_by(id: period_id)
      approver = TimeTrackerExtension::PeriodApprover.new(period)
      if approver.perform
        answer_callback_query(t('telegram.done'))
        edit_message("text", { text: t('telegram.period_was_succesfully_approved', workspace: period.workspace.name, from: period.beginning_of_period, to: period.end_of_period) })
      else
        answer_callback_query(t('telegram.error', message: approver.period.errors[:base].join(', ')))
      end
    end

    def today_tasks!(*)
      message_generator = TimeTrackerExtension::TelegramMessageGenerators::TodayTasks.new(current_user)
      respond_with :message, text: message_generator.perform
    end

    def active_task!(*)
      message_generator = TimeTrackerExtension::TelegramMessageGenerators::ActiveTask.new(current_user)
      respond_with :message, message_generator.perform
    end

    def stop_active_task_callback_query(time_record_id = nil, *)
      time_record = current_user.time_records.find(time_record_id)
      time_record.update(time_start: nil, spent_time: time_record.calculated_spent_time)
      answer_callback_query(t("telegram.done"))
      edit_message("text", { text: t('telegram.task_was_stopped', description: time_record.description, time: time_record.calculated_spent_time, project: time_record.project.name) })
    end

    def total_time!(*)
      week_button = Telegram::Bot::Types::InlineKeyboardButton.new(text: t("telegram.total_time.week"), callback_data: "total_time:week")
      month_button = Telegram::Bot::Types::InlineKeyboardButton.new(text: t("telegram.total_time.month"), callback_data: "total_time:month")
      respond_with :message, {
        text: t("telegram.total_time.select_period"),
        reply_markup: { inline_keyboard: [[week_button, month_button]] }
      }
    end

    def total_time_callback_query(period, *)
      message_generator = TimeTrackerExtension::TelegramMessageGenerators::TotalTime.new(current_user, period)
      edit_message("text", { text: message_generator.perform })
    end

    def unapproved_reports!(*)
      respond_with(:message, { text: t("telegram.forbidden") }) and return if current_user.staff?

      message_generator = TimeTrackerExtension::TelegramMessageGenerators::UnapprovedReports.new(current_user)
      respond_with :message, text: message_generator.perform
    end

    private

    def current_user
      @user ||= User.find_by(telegram_id: from["id"])
    end

    def user_session
      session[current_user.id] || session[current_user.id] = {}
    end

    def with_locale(&block)
      I18n.with_locale(locale, &block)
    end

    def with_time_zone
      # TODO: change this when we start to keep timezone in user's model
      timezone = 3
      Time.use_zone(timezone) { yield }
    end

    def locale
      return current_user.locale if current_user

      from["language_code"] if User::SUPPORTED_LANGUAGES.include?(from["language_code"])
    end

    def link_user_account(user)
      text = if current_user && current_user != user
        save_context(:set_token!)
        t('telegram.this_account_was_linked')
      else
        user.update(telegram_id: from["id"])
        t('telegram.telegram_was_assigned_to_account')
      end

      respond_with :message, text:  text
    end

    def authorize_user
      unless current_user
        respond_with(:message, { text: t("telegram.please_link_your_account_first") })
        throw :abort
      end
    end
  end
end
