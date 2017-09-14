class AddForgotPasswordToken < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :forgot_password_token, :string
  end
end
