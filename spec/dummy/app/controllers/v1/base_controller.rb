class V1::BaseController < ApplicationController
  include Pundit

  before_action :authenticate
  after_action :set_token

  def current_workspace_id
    @current_workspace_id ||= if current_user
      current_user.active_workspace_id
    end
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
