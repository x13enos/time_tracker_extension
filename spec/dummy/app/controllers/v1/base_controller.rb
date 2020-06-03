include ActionController::Cookies

class V1::BaseController < ApplicationController
  include Pundit

  before_action :authenticate
  after_action :set_token

  def current_user
  end

  def current_workspace_id
  end

  private

  def authenticate
  end

  def set_token
  end

  def decode(passed_token)
    TokenCryptService.decode(passed_token)
  end
end
