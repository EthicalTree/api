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
    assert @request.session[:user_id]
  end

  test 'if your account is unverified then resend confirmation page should show instead of logging in' do
    user = create :user, email: 'test@test.com', password: 'password', password_confirmation: 'password', confirmed_at: nil
    post :create, params: { session: { email: 'test@test.com', password: 'password' }}
    assert_template 'sessions/confirm_email_sent'
  end

  test 'logging out should remove the current user from the session' do
    user = create :user
    login user
    post :destroy
    assert_nil @request.session[:user_id]
  end
end