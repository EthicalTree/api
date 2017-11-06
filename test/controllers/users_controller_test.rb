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

  test 'forgot password link endpoint should generate a forgot password token' do
    user = create :user, email: 'test@test.com'
    assert_not user.forgot_password_token

    get :forgot_password, params: { email: 'test@test.com' }
    user.reload
    token = user.forgot_password_token
    assert token

    get :forgot_password, params: { email: 'test@test.com' }
    user.reload
    assert token != user.forgot_password_token

    # test user doesn't exist
    res = get :forgot_password, params: { email: 'nonexistant@test.com' }
    assert JSON.parse(res.body)["errors"]
  end

  test 'forgot password should reset password when supplied with correct token' do
    user = create :user, email: 'test@test.com', forgot_password_token: 'token'
    digest = user.password_digest

    # shouldn't work when token not sent
    res = get :forgot_password, params: { token: nil }
    assert JSON.parse(res.body)["errors"]

    get :forgot_password, params: { token: 'token', password: 'abc123!@#', password_confirmation: 'abc123!@#' }
    user.reload
    assert digest != user.password_digest

    # check password errors are handles properly
    res = get :forgot_password, params: { token: 'token', password: 'abc123!@#', password_confirmation: '' }
    assert JSON.parse(res.body)["errors"]

    # token check
    res = get :forgot_password, params: { token: 'token', check: true}
    assert JSON.parse(res.body)["email"]
  end

  test 'requesting current user should show the current user' do
    user = create :user
    authorize user
    res = get :show, params: { id: 'current' }
    assert JSON.parse(res.body)["user"]["id"] == user.id
  end

  test 'updating current user should update current user params' do
    user = create :user, first_name: 'Test', last_name: 'Name'
    authorize user
    res = put :update, params: {
      id: 'current',
      user: {
        first_name: 'New',
        last_name: 'Testname'
      }
    }

    user.reload
    assert user.first_name == 'New'
    assert user.last_name == 'Testname'
  end

  test 'should not be able to update password without providing current password' do
    user = create :user, first_name: 'Test', last_name: 'Name', password: 'abc123!@#', password_confirmation: 'abc123!@#'
    digest = user.password_digest

    authorize user
    res = put :update, params: {
      id: 'current',
      user: {
        password: '!@#abc123',
        password_confirmation: '!@#abc123',
      }
    }

    assert JSON.parse(res.body)["errors"]

    res = put :update, params: {
      id: 'current',
      user: {
        password: '!@#abc123',
        password_confirmation: '!@#abc123',
        current_password: 'abc123!@#',
      }
    }

    user.reload
    assert user.password_digest != digest
  end

end
