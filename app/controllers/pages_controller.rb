class PagesController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:auth]

  def auth
  end

  def messages
  end

  def notification
  end

  def settings
  end
end