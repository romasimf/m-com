class Conversation < ApplicationRecord
  belongs_to :user_one, class_name: "User"
  belongs_to :user_two, class_name: "User"

  has_many :messages, dependent: :destroy

  validates :user_one_id, presence: true
  validates :user_two_id, presence: true
  validate :users_must_be_different

  scope :for_user, ->(user) {
    where("user_one_id = :user_id OR user_two_id = :user_id", user_id: user.id)
  }

  def self.between(first_user, second_user)
    first_id, second_id = [first_user.id, second_user.id].sort

    find_or_create_by!(
      user_one_id: first_id,
      user_two_id: second_id
    )
  end

  def other_user(user)
    user_one_id == user.id ? user_two : user_one
  end

  def last_message
    messages.order(created_at: :desc).first
  end

  def unread_for?(user)
    messages.where.not(user_id: user.id).where(read_at: nil).exists?
  end

  private

  def users_must_be_different
    if user_one_id.present? && user_two_id.present? && user_one_id == user_two_id
      errors.add(:base, "Нельзя создать диалог с самим собой")
    end
  end
end