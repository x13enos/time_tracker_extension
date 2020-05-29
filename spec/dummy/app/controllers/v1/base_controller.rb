class V1::BaseController < ApplicationController
  include Pundit

  before_action :authenticate
  after_action :set_token

  private

  def authenticate
  end

  def set_token
  end

  def decode(passed_token)
    TokenCryptService.decode(passed_token)
  end
end
