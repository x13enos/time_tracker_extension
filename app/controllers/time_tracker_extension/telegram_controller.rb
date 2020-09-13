module TimeTrackerExtension
  class TelegramController < Telegram::Bot::UpdatesController
    include Telegram::Bot::UpdatesController::MessageContext
    include Telegram::Bot::UpdatesController::CallbackQueryContext

    use_session!
    self.session_store = :memory_store

    around_action :with_locale


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
      if period.approve!
        answer_callback_query(t('telegram.done'))
        edit_message("text", { text: t('telegram.period_was_succesfully_approved', workspace: period.workspace.name, from: period.beginning_of_period, to: period.end_of_period) })
      else
        answer_callback_query(t('telegram.error', message: period.errors[:base].join(', ')))
      end
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
  end
end
