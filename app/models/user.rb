class User < ApplicationRecord
  has_one_attached :avatar

  has_many :posts, dependent: :destroy

  before_validation :set_random_name_and_username, on: :create
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :messages, dependent: :destroy

  has_many :active_follows,
           class_name: "Follow",
           foreign_key: "follower_id",
           dependent: :destroy

  has_many :passive_follows,
           class_name: "Follow",
           foreign_key: "followed_id",
           dependent: :destroy

  has_many :following,
           through: :active_follows,
           source: :followed

  has_many :followers,
           through: :passive_follows,
           source: :follower

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  validates :name, length: { maximum: 50 }, allow_blank: true

  validates :username,
            uniqueness: true,
            length: { maximum: 30 },
            format: {
              with: /\A[a-zA-Z0-9_]*\z/,
              message: "может содержать только буквы, цифры и _"
            },
            allow_blank: true

  def display_name
    name.presence || email.to_s.split("@").first.capitalize
  end

  def tag_name
    username.presence || email.to_s.split("@").first.downcase
  end

  def following?(user)
    following.exists?(user.id)
  end

  def follow(user)
    active_follows.find_or_create_by(followed: user) unless self == user
  end

  def unfollow(user)
    active_follows.find_by(followed: user)&.destroy
  end

  private

  def set_random_name_and_username
    self.name = generate_random_name if name.blank?
    self.username = generate_random_username if username.blank?
  end

  def generate_random_name
    adjective = %w[Swift Deep Cool Wild Neo Dark Blue Zen Bold Red Luxe].sample
    noun = %w[Fox Wolf Bear Hawk Lynx Owl Vibe Flow Peak Edge Wave].sample
    "#{adjective}#{noun}#{rand(10..999)}"
  end

  def generate_random_username
    loop do
      token = SecureRandom.alphanumeric(6).downcase
      username_candidate = "u_#{token}"
      break username_candidate unless User.exists?(username: username_candidate)
    end
  end
end