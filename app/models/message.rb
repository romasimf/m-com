class Message < ApplicationRecord
  belongs_to :conversation, touch: true
  belongs_to :user

  before_validation :clean_body

  validates :body, presence: true, length: { maximum: 2000 }

  after_create_commit :broadcast_message

  private

  def clean_body
    self.body = body.to_s.strip
  end

  def broadcast_message
    [conversation.user_one, conversation.user_two].each do |user|
      next unless user

      unless user == self.user
        broadcast_append_to "messages_for_user_#{user.id}",
          target: "messages",
          partial: "messages/message",
          locals: { message: self, viewer_id: user.id }
      end

      broadcast_replace_to "sidebar_for_user_#{user.id}",
        target: "conv_sidebar_#{conversation.id}",
        partial: "conversations/conversation_sidebar",
        locals: { conversation: conversation, current_user: user }

      unread = Message.joins(:conversation)
        .where(read_at: nil)
        .where.not(user_id: user.id)
        .where("conversations.user_one_id = :uid OR conversations.user_two_id = :uid", uid: user.id)
        .count

      broadcast_replace_to "unread_messages_for_user_#{user.id}",
        target: "unread-badge-sidebar-count",
        partial: "messages/badge_count",
        locals: { count: unread, target_id: "unread-badge-sidebar-count" }

      broadcast_replace_to "unread_messages_for_user_#{user.id}",
        target: "unread-badge-mobile-count",
        partial: "messages/badge_count",
        locals: { count: unread, target_id: "unread-badge-mobile-count" }

      unless user == self.user
        broadcast_render_to "notifications_for_user_#{user.id}",
          partial: "messages/notification",
          locals: { message: self, unread_count: unread }
      end
    end
  end
end