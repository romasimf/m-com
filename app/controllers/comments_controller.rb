class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      if request.content_type&.include?("json")
        render json: {
          id: @comment.id,
          userName: current_user.name.presence || current_user.email.split("@").first.capitalize,
          userUsername: current_user.username.presence || current_user.email.split("@").first.downcase,
          avatarUrl: current_user.avatar.attached? ? url_for(current_user.avatar) : "",
          body: @comment.body.to_s,
          createdAt: @comment.created_at.strftime("%d.%m.%Y %H:%M")
        }, status: :created
        return
      end

      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html { redirect_back fallback_location: profile_path }
      end
      return
    end

    flash[:alert] = "Комментарий не может быть пустым"
    redirect_back fallback_location: profile_path
  end

  def destroy
    @comment = @post.comments.find(params[:id])

    if @comment.user == current_user || @post.user == current_user
      @comment.destroy
      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html { redirect_back fallback_location: profile_path }
      end
      return
    end

    flash[:alert] = "Вы не можете удалить этот комментарий"
    redirect_back fallback_location: profile_path
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end