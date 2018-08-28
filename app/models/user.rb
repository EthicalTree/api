class User < ApplicationRecord
  has_secure_password

  before_create :confirmation_token

  has_many :owned_listings, foreign_key: :owner_id, class_name: "Listing"

  validates :email, presence: true, email: true, uniqueness: true
  validate :password_cannot_be_present_without_confirmation
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
    as_json(only: [:id, :first_name, :last_name, :email, :admin])
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

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def display_name options={}
    only_first = options[:only_first]

    if only_first && first_name.present?
      first_name
    elsif full_name.present?
      full_name
    else
      email
    end
  end

  def display_name_with_email
    if full_name.present?
      "#{full_name} (#{email})"
    else
      email
    end
  end

  def serializable_hash options={}
    super((options || {}).merge({
      except: [:password_digest, :confirm_token],
      methods: [
        :display_name,
        :display_name_with_email
      ]
    }))
  end

private

  def confirmation_token
    if self.confirm_token.blank?
      self.regenerate_token
    end
  end

  def password_cannot_be_present_without_confirmation
    if password && !password_confirmation
      errors.add(:password_confirmation, "You must confirm your password")
    end
  end

end
