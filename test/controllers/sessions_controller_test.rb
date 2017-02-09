require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  test 'using the wrong password should not log you in' do
    post :create, params: { session: { email: 'test@test.com', password: 'wrong' }}
    assert flash[:login].present?
  end

  test 'using the right password should log you in' do
    user = create :user, email: 'test@test.com', password: 'awesomeright1', password_confirmation: 'awesomeright1'
    post :create, params: { session: { email: 'test@test.com', password: 'awesomeright1' }}
    assert_not flash[:login].present?
  end
end