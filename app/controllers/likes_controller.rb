class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    @post.likes.find_or_create_by(user: current_user)
    broadcast_likes_count
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: profile_path }
    end
  end

  def destroy
    @post.likes.where(user: current_user).destroy_all
    broadcast_likes_count
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: profile_path }
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def broadcast_likes_count
    count = @post.likes.count
    target = "likes_count_#{@post.id}"
    @post.broadcast_replace_to [@post, :likes],
      target: target,
      html: "<span id=\"#{target}\">#{count}</span>".html_safe
  end
end