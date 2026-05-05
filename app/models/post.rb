class Post < ApplicationRecord
  belongs_to :user

  has_many_attached :images

  validates :body, length: { maximum: 500 }
  validate :body_or_images_present
  validate :images_count_within_limit

  private

  def body_or_images_present
    if body.blank? && !images.attached?
      errors.add(:base, "Пост не может быть пустым")
    end
  end

  def images_count_within_limit
    if images.count > 5
      errors.add(:images, "можно загрузить не больше 5 фото")
    end
  end
end
