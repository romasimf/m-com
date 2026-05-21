class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  MAX_IMAGES = 6

  def new
    @post = current_user.posts.build
  end

  def create
    uploaded_images = selected_images
    @post = current_user.posts.build(post_text_params)

    if uploaded_images.size > MAX_IMAGES
      @post.errors.add(:images, "можно добавить не больше #{MAX_IMAGES} фотографий")
      render :new, status: :unprocessable_entity
      return
    end

    @post.images.attach(uploaded_images) if uploaded_images.any?

    if @post.save
      redirect_to profile_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    uploaded_images = selected_images
    remove_ids = selected_remove_image_ids

    remaining_images_count = @post.images.attachments.reject { |attachment| remove_ids.include?(attachment.id.to_s) }.size
    total_images_count = remaining_images_count + uploaded_images.size

    if total_images_count > MAX_IMAGES
      @post.errors.add(:images, "можно добавить не больше #{MAX_IMAGES} фотографий")
      render :edit, status: :unprocessable_entity
      return
    end

    @post.assign_attributes(post_text_params)

    @post.images.attachments.where(id: remove_ids).each(&:purge) if remove_ids.any?
    @post.images.attach(uploaded_images) if uploaded_images.any?

    if @post.save
      redirect_to profile_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to profile_path
  end

  private

  def set_post
    @post = current_user.posts.find(params[:id])
  end

  def post_text_params
    params.require(:post).permit(:body)
  end

  def selected_images
    Array(params.dig(:post, :images)).reject(&:blank?)
  end

  def selected_remove_image_ids
    Array(params.dig(:post, :remove_image_ids)).reject(&:blank?)
  end
end
