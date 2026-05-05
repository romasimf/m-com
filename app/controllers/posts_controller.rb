class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]

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
    removed_ids = params[:post][:removed_image_ids].to_s.split(",").reject(&:blank?)
    new_images  = Array(params.dig(:post, :images)).reject(&:blank?)
    new_body    = params[:post][:body].to_s.strip

    current_images = @post.images.attachments.to_a
    remaining_images_count = current_images.count - removed_ids.count
    remaining_images_count = 0 if remaining_images_count.negative?

    total_images = remaining_images_count + new_images.count

    if total_images > 5
      @post.assign_attributes(body: params[:post][:body])
      @removed_image_ids = removed_ids
      @post.errors.add(:images, "Можно загрузить не больше 5 фото")
      render :edit, status: :unprocessable_entity
      return
    end

    if new_body.blank? && total_images.zero?
      @post.assign_attributes(body: params[:post][:body])
      @removed_image_ids = removed_ids
      @post.errors.add(:base, "Пост не может быть пустым")
      render :edit, status: :unprocessable_entity
      return
    end

    newly_attached = []

    if new_images.present?
      before_ids = @post.images.attachments.pluck(:id)
      @post.images.attach(new_images)
      after_attachments = @post.images.attachments.reload
      newly_attached = after_attachments.reject { |attachment| before_ids.include?(attachment.id) }
    end

    @post.assign_attributes(body: params[:post][:body])

    if @post.save
      current_images.each do |attachment|
        attachment.purge if removed_ids.include?(attachment.id.to_s)
      end

      redirect_to profile_path, notice: "Пост обновлён"
    else
      newly_attached.each(&:purge)
      @removed_image_ids = removed_ids
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
