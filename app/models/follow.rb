class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true
  validates :followed_id, presence: true
  validates :followed_id, uniqueness: { scope: :follower_id }

  validate :user_cannot_follow_himself

  after_create_commit :broadcast_follow_update
  after_destroy_commit :broadcast_follow_update

  private

  def user_cannot_follow_himself
    if follower_id.present? && followed_id.present? && follower_id == followed_id
      errors.add(:base, "Нельзя подписаться на самого себя")
    end
  end

  def broadcast_follow_update
    broadcast_replace_to "followers_#{followed_id}",
      target: "followers_count_#{followed_id}",
      partial: "profiles/followers_count",
      locals: { user: followed }
  end
end