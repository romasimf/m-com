class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to profile_path, notice: "Пост опубликован"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    new_images = params.dig(:post, :images)&.reject(&:blank?)

    if @post.update(body: params[:post][:body])
      if new_images.present?
        @post.images.purge
        @post.images.attach(new_images)
      end

      redirect_to profile_path, notice: "Пост обновлён"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to profile_path, notice: "Пост удалён"
  end

  private

  def set_post
    @post = current_user.posts.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:body, images: [])
  end
end