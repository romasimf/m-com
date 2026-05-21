class Post < ApplicationRecord
  belongs_to :user
  has_many_attached :images

  validates :body, length: { maximum: 1000 }
  validate :body_or_images_present
  validate :images_count_within_limit

  private

  def body_or_images_present
    if body.blank? && images.attachments.blank?
      errors.add(:base, "Пост не может быть пустым")
    end
  end

  def images_count_within_limit
    if images.attachments.size > 6
      errors.add(:images, "можно добавить не больше 6 фотографий")
    end
  end
end
