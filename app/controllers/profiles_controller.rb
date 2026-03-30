class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @posts = current_user.posts.includes(images_attachments: :blob).order(created_at: :desc)
  end
end