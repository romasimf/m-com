class Post < ApplicationRecord
  belongs_to :user
  has_many_attached :images

  validates :body, length: { maximum: 1000 }
  validate :body_or_images_present

  private

  def body_or_images_present
    if body.blank? && !images.attached?
      errors.add(:base, "Пост не может быть пустым")
    end
  end
end