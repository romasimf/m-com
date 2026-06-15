module ApplicationHelper
  def unread_messages_count(user)
    return 0 unless user

    Message.joins(:conversation)
      .where(read_at: nil)
      .where.not(user_id: user.id)
      .where("conversations.user_one_id = :uid OR conversations.user_two_id = :uid", uid: user.id)
      .count
  end
end
