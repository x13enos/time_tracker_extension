ENV['RAILS_ENV'] ||= 'test'
require File.expand_path("../dummy/config/environment.rb", __FILE__)
require 'factory_bot_rails'
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

require 'telegram/bot'
require 'telegram/bot/types'
require 'spec_helper'
require 'rspec/rails'
require 'database_cleaner'
require 'faker'
require 'pry'
require 'shoulda/matchers'
require 'pundit/rspec'
require 'pundit/matchers'

ActiveRecord::Migration.maintain_test_schema!

FactoryBot::SyntaxRunner.class_eval do
  include ActionDispatch::TestProcess
end

RSpec.configure do |config|

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.include ActiveSupport::Testing::TimeHelpers

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.render_views = true

  config.after { Telegram.bot.reset }

  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)
end
