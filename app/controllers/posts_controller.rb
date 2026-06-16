class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:edit, :update, :destroy]
  before_action :check_owner!, only: [:edit, :update, :destroy]

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)

    unless validate_uploaded_files
      return render_post_form
    end

    if @post.save
      if params[:form_source] == "home"
        respond_to do |format|
          format.turbo_stream { head :ok }
          format.html { redirect_to root_path, notice: "Пост опубликован" }
        end
      else
        redirect_to root_path, notice: "Пост опубликован"
      end
    else
      render_post_form
    end
  end

  def edit
  end

  def update
    remove_selected_images

    unless validate_uploaded_files
      return render :edit, status: :unprocessable_entity
    end

    update_params = post_params
    new_files = Array(update_params[:images]).reject(&:blank?)
    update_params.delete(:images)

    new_files.each { |file| @post.images.attach(file) }

    if @post.update(update_params)
      redirect_to profile_path, notice: "Пост обновлён"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("post_#{@post.id}") }
      format.html { redirect_to profile_path, notice: "Пост удалён" }
    end
  end

  private

    def load_home_page_data
    @posts = Post.includes(:user, images_attachments: :blob, likes: :user, comments: :user)
                .order(created_at: :desc)

    @search_query = params[:q].to_s.strip

    @search_results =
      if @search_query.present?
        safe_query = ActiveRecord::Base.sanitize_sql_like(@search_query)

        User.where.not(id: current_user.id)
            .where("name ILIKE ?", "%#{safe_query}%")
            .order(:name)
            .limit(10)
      else
        []
      end
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def check_owner!
    redirect_to root_path, alert: "Нет доступа" unless @post.user == current_user
  end

  def post_params
    params.require(:post).permit(:body, images: [])
  end

  def remove_selected_images
    Array(params[:remove_image_ids]).each do |image_id|
      image = @post.images.attachments.find_by(id: image_id)
      image&.purge
    end
  end

  def validate_uploaded_files
    files = Array(post_params[:images]).reject(&:blank?)
    return true if files.empty?

    files.each do |file|
      unless Post::ALLOWED_TYPES.include?(file.content_type)
        @post.errors.add(:images, "неподдерживаемый тип файла")
        return false
      end

      if file.size > Post::MAX_FILE_SIZE
        @post.errors.add(:images, "файл слишком большой (максимум 100 МБ)")
        return false
      end
    end

    true
  end

  def render_post_form
    if params[:form_source] == "home"
      load_home_page_data
      render "home/index", status: :unprocessable_entity
    else
      render :new, status: :unprocessable_entity
    end
  end
end