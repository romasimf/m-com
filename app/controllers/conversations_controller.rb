class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index
    load_sidebar_data
  end

  def show
    load_sidebar_data

    @conversation = Conversation
                    .for_user(current_user)
                    .includes(messages: :user)
                    .find(params[:id])

    @other_user = @conversation.other_user(current_user)
    @message = Message.new
    @messages = @conversation.messages.includes(:user).order(created_at: :asc)

    mark_messages_as_read
  end

  def create
    user = User.find(params[:user_id])

    if user == current_user
      redirect_to messages_path, alert: "Нельзя написать самому себе"
      return
    end

    conversation = Conversation.between(current_user, user)

    redirect_to conversation_path(conversation)
  end

  private

  def load_sidebar_data
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

    @conversations = Conversation
                     .for_user(current_user)
                     .includes(:user_one, :user_two, messages: :user)
                     .order(updated_at: :desc)
  end

  def mark_messages_as_read
    @conversation.messages
                 .where.not(user_id: current_user.id)
                 .where(read_at: nil)
                 .update_all(read_at: Time.current, updated_at: Time.current)
  end
end