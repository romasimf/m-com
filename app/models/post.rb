class Post < ApplicationRecord
  belongs_to :user

  has_many_attached :images

  after_create_commit :broadcast_post
  after_destroy_commit :broadcast_post_removal

  has_many :likes, dependent: :destroy
  has_many :comments, -> { order(created_at: :asc) }, dependent: :destroy

  MAX_FILES = 5
  MAX_FILE_SIZE = 100.megabytes
  ALLOWED_TYPES = %w[
    image/jpeg image/png image/gif image/webp
    video/mp4 video/webm video/quicktime
  ].freeze

  validates :body, length: { maximum: 1000 }

  validate :body_or_media_present
  validate :files_count_within_limit
  validate :file_type_and_size_valid

  def liked_by?(user)
    return false unless user

    if likes.loaded?
      likes.any? { |like| like.user_id == user.id }
    else
      likes.exists?(user_id: user.id)
    end
  end

  private

  def broadcast_post_removal
    broadcast_remove_to "posts"
  end

  def broadcast_post
    ActiveStorage::Current.set(url_options: Rails.application.routes.default_url_options) do
      broadcast_prepend_to "posts",
        target: "posts-list",
        partial: "posts/post",
        locals: { post: self, current_user: nil }
    end

    ActiveStorage::Current.set(url_options: Rails.application.routes.default_url_options) do
      User.where.not(id: user.id).select(:id).find_each do |other_user|
        broadcast_render_to "notifications_for_user_#{other_user.id}",
          partial: "posts/notification",
          locals: { post: self }
      end
    end
  end

  def body_or_media_present
    if body.blank? && images.attachments.blank? && pending_files_count.zero?
      errors.add(:base, "Пост не может быть пустым")
    end
  end

  def files_count_within_limit
    count = new_record? ? pending_files_count : images.attachments.size + pending_files_count

    if count > MAX_FILES
      errors.add(:images, "можно добавить не больше #{MAX_FILES} файлов")
    end
  end

  def file_type_and_size_valid
    pending_blobs.each do |blob|
      unless ALLOWED_TYPES.include?(blob.content_type)
        errors.add(:images, "содержит файл неподдерживаемого типа")
        return
      end

      if blob.byte_size > MAX_FILE_SIZE
        errors.add(:images, "файл слишком большой (максимум 100 МБ)")
        return
      end
    end

    images.attachments.each do |attachment|
      unless ALLOWED_TYPES.include?(attachment.blob.content_type)
        errors.add(:images, "содержит файл неподдерживаемого типа")
        return
      end

      if attachment.blob.byte_size > MAX_FILE_SIZE
        errors.add(:images, "файл слишком большой (максимум 100 МБ)")
        return
      end
    end
  end

  def pending_files_count
    return 0 unless respond_to?(:attachment_changes)
    change = attachment_changes["images"]
    return 0 if change.nil?

    if change.respond_to?(:attachables)
      change.attachables.reject(&:blank?).size
    elsif change.respond_to?(:attachable)
      change.attachable.present? ? 1 : 0
    else
      0
    end
  end

  def pending_blobs
    return [] unless respond_to?(:attachment_changes)
    change = attachment_changes["images"]
    return [] if change.nil?

    if change.respond_to?(:blobs)
      change.blobs
    elsif change.respond_to?(:blob)
      [change.blob]
    else
      []
    end
  end
end
