class User < ApplicationRecord
  has_secure_password

  before_create :confirmation_token

  validates :email, presence: true, email: true, uniqueness: true

  def confirm!
    update!(confirmed_at: DateTime.current)
  end

  def confirmed?
    !! confirmed_at
  end

  def display_name
    "#{first_name} #{last_name}"
  end

  def as_json options=nil
    super(only: [:id, :first_name, :last_name])
  end

  def regenerate_token
    self.confirm_token = SecureRandom.urlsafe_base64(4)
  end

private

  def confirmation_token
    if self.confirm_token.blank?
      self.regenerate_token
    end
  end

end
