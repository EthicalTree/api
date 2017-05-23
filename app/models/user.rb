class User < ApplicationRecord
  has_secure_password

  before_create :confirmation_token

  validates :email, presence: true, email: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

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

private

  def confirmation_token
    if self.confirm_token.blank?
        self.confirm_token = SecureRandom.urlsafe_base64.to_s
    end
  end

end
