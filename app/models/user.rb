class User < ApplicationRecord
  has_secure_password

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

end
