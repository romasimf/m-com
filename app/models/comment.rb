class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :body, presence: true, length: { maximum: 500 }

  after_create_commit :broadcast_comment
  after_destroy_commit :broadcast_comment_destroy

  private

  def broadcast_comment
    broadcast_append_to [post, :comments],
      target: "comments_list_#{post.id}",
      partial: "comments/comment",
      locals: { comment: self }

    broadcast_replace_to [post, :comments],
      target: "comments_count_#{post.id}",
      partial: "comments/comment_count",
      locals: { post: post }
  end

  def broadcast_comment_destroy
    broadcast_remove_to [post, :comments],
      target: "comment_#{id}"

    broadcast_replace_to [post, :comments],
      target: "comments_count_#{post.id}",
      partial: "comments/comment_count",
      locals: { post: post }
  end
end