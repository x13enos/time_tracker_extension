require 'telegram/bot'
require 'telegram/bot/types'

if Rails.env.test?
  Telegram.reset_bots
  Telegram::Bot::ClientStub.stub_all!
end

Telegram.bots_config = {
  default: ENV["TELEGRAM_BOT_TOKEN"]
}
