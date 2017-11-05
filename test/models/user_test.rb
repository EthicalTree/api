require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @subject = FactoryGirl.build :user
  end

  should validate_presence_of(:email)
  should validate_presence_of(:password)

  test "email should be unique" do
    create(:user, email: "email@domain.com")

    @subject.email = "email@domain.com"
    @subject.valid?

    assert_includes(@subject.errors[:email], "has already been taken")
  end

  test "user should be authenticatable" do
    user = create :user, password: "123abc%%456", password_confirmation: '123abc%%456'

    assert_not(user.authenticate("qwerty"))
    assert(user.authenticate("123abc%%456"))
  end

  test "should confirm the user" do
    user = create :user, confirmed_at: nil

    assert_not(user.confirmed?)

    user.confirm!

    assert(user.confirmed?)
  end

  test "user should generate a confirmation token when created" do
    user = build :user, confirm_token: nil
    assert_not user.confirm_token
    user.save
    assert user.confirm_token
  end

  test "user display name should be first and last name combined" do
    user = build :user, first_name: 'test', last_name: 'test'
    assert user.display_name == 'test test'
  end

end
