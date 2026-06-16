class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    load_user_search
    load_unread_messages
    load_new_posts

    current_user.update_column(:notifications_seen_at, Time.current)
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

  def load_unread_messages
    @unread_messages =
      Message.joins(:conversation)
             .where(read_at: nil)
             .where.not(user_id: current_user.id)
             .where(
               "conversations.user_one_id = :user_id OR conversations.user_two_id = :user_id",
               user_id: current_user.id
             )
             .includes(:user, conversation: [:user_one, :user_two])
             .order(created_at: :desc)
             .limit(50)
  end

  def load_new_posts
    previous_seen_time = current_user.notifications_seen_at

    posts_scope =
      Post.where.not(user_id: current_user.id)
          .includes(:user, images_attachments: :blob)
          .order(created_at: :desc)

    posts_scope = posts_scope.where("posts.created_at > ?", previous_seen_time) if previous_seen_time.present?

    @new_posts = posts_scope.limit(50)
  end
end