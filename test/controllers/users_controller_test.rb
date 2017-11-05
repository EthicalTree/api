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

  test 'password should not be allowed to be weak' do
    post :create, params: {
      user: {
        email: 'test@test.com',
        password: 'password',
        password_confirmation: 'password'
      }
    }
    assert_not User.find_by email: 'test@test.com'
  end

  test 'password confirmation must be present when password set' do
    post :create, params: {
      user: {
        email: 'test@test.com',
        password: 'password'
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

  test 'creating unconfirmed user should generate new token' do
    user = User.create email: 'test@test.com', password: '123abc%%456', password_confirmation: '123abc%%456'
    assert user.confirm_token
    token = user.confirm_token
    digest = user.password_digest

    post :create, params: {
      user: {
        email: 'test@test.com',
        password: 'abc123!@#',
        password_confirmation: 'abc123!@#'
      }
    }

    new_user = User.find_by email: 'test@test.com'
    assert new_user.confirm_token != token
    assert new_user.password_digest != digest
  end

  test 'correct info should create user' do
    deliver_later = stub(deliver_later: nil)
    AccountMailer.stubs(:confirm_email).returns(deliver_later)
    deliver_later.expects(:deliver_later).once

    post :create, params: {
      user: {
        email: 'test@test.com',
        password: '123abc%%456',
        password_confirmation: '123abc%%456'
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
