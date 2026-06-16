class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = params[:id].present? ? User.find(params[:id]) : current_user

    @posts = @user.posts
                  .includes(:user, images_attachments: :blob, likes: :user, comments: [:user])
                  .order(created_at: :desc)

    @followers_count = @user.followers.count
    @following_count = @user.following.count

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