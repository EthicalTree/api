require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test 'passwords that dont match should give error' do
    post :create, params: {
      user: {
        email: 'test@test.com',
        first_name: 'test',
        last_name: 'test',
        password: 'password',
        password_confirmation: 'wrong'
      }
    }
    assert_not User.find_by email: 'test@test.com'
  end

  test 'fields should have values' do
    post :create, params: {
      user: {
        email: 'test@test.com',
        first_name: '',
        last_name: 'test',
        password: 'password',
        password_confirmation: 'wrong'
      }
    }
    assert_not User.find_by email: 'test@test.com'

    post :create, params: {
      user: {
        email: 'test@test.com',
        first_name: 'test',
        last_name: '',
        password: 'password',
        password_confirmation: 'wrong'
      }
    }
    assert_not User.find_by email: 'test@test.com'
  end

  test 'correct info should create user' do
    post :create, params: {
      user: {
        email: 'test@test.com',
        first_name: 'test',
        last_name: 'test',
        password: 'password',
        password_confirmation: 'password'
      }
    }

    assert User.find_by email: 'test@test.com'
  end

end