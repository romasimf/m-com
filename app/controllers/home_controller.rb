class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @post = current_user.posts.build

    @posts = Post.includes(:user, images_attachments: :blob, likes: :user, comments: :user)
                 .order(created_at: :desc)

    load_user_search
  end

  private

  def load_user_search
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
end