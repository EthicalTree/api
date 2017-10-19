class User < ApplicationRecord
  has_secure_password

  before_create :confirmation_token

  has_many :owned_listings, foreign_key: :owner_id, class_name: "Listing"

  validates :email, presence: true, email: true, uniqueness: true
  validates_strength_of :password, with: :email,
    if: Proc.new { |m| m.password && m.password_confirmation }

  def confirm!
    update!(confirmed_at: DateTime.current)
  end

  def confirmed?
    !! confirmed_at
  end

  def display_name
    "#{first_name} #{last_name}"
  end

  def as_json_basic options=nil
    as_json(only: [:id, :first_name, :last_name], methods: :can_edit_listing)
  end

  def regenerate_token
    self.confirm_token = SecureRandom.urlsafe_base64(4)
  end

  def regenerate_forgot_password_token
    self.forgot_password_token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless User.exists?(forgot_password_token: random_token)
    end
    self.save
  end

  def forgot_password_link
    domain = Rails.application.secrets[:webhost]
    "https://#{domain}/forgot_password/#{self.forgot_password_token}"
  end

  def can_edit_listing
    true
  end

private

  def confirmation_token
    if self.confirm_token.blank?
      self.regenerate_token
    end
  end

end
