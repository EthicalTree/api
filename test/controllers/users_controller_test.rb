require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test 'passwords that dont match should give error' do
    post :create, params: {
      user: {
        email: 'test@test.com',
        password: 'password',
        password_confirmation: 'wrong'
      }
    }
    assert_not User.find_by email: 'test@test.com'
  end

  test 'fields should have values' do
    post :create, params: {
      user: {
        email: '',
        password: 'password',
        password_confirmation: 'wrong'
      }
    }
    assert_not User.find_by email: 'test@test.com'

    post :create, params: {
      user: {
        email: 'test@test.com',
        password: '',
        password_confirmation: 'wrong'
      }
    }
    assert_not User.find_by email: 'test@test.com'
  end

  test 'correct info should create user' do
    deliver_later = stub(deliver_later: nil)
    AccountMailer.stubs(:confirm_email).returns(deliver_later)
    deliver_later.expects(:deliver_later).once

    post :create, params: {
      user: {
        email: 'test@test.com',
        password: 'password',
        password_confirmation: 'password'
      }
    }

    user = User.find_by email: 'test@test.com'

    assert user
    assert_not user.confirmed?
  end

  test 'confirming with invalid token should fail' do
    user = create :user, confirmed_at: nil, confirm_token: 'myspecialtoken'

    get :confirm_email, params: { token: 'invalidtoken' }
    assert_not user.reload.confirmed?

    get :confirm_email, params: { token: 'myspecialtoken' }
    assert user.reload.confirmed?
  end

end
