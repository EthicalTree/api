
const session = (state={}, action) => {

  switch (action.type) {
    case 'SET_LOGIN_INFO':
      return {...state, loginInfo: action.data}
    case 'SET_LOGIN_MODAL':
      return {...state, isLoggingIn: action.data}
    case 'SET_LOGOUT_MODAL':
      return {...state, isLoggingOut: action.data}
    case 'SET_SIGNUP_MODAL':
      return {...state, isSigningUp: action.data}
    case 'SET_VERIFYING_EMAIL_MODAL':
      return {...state, isVerifyingEmail: action.data}
    case 'SET_LOGIN_LOADING':
      return {...state, loginLoading: action.data}
    case 'SET_LOGOUT_LOADING':
      return {...state, logoutLoading: action.data}
    case 'SET_SIGNUP_LOADING':
      return {...state, signupLoading: action.data}
    case 'SET_VERIFY_EMAIL_LOADING':
      return {...state, verifyEmailLoading: action.data}
    case 'SET_LOGIN_ERROR':
      return {...state, loginError: action.data}
    case 'SET_SIGNUP_ERROR':
      return {...state, signupErrors: action.data}
    case 'SET_VERIFY_EMAIL_ERROR':
      return {...state, verifyEmailErrors: action.data}
    case 'LOGIN':
      return {
        ...state,
        loginError: false,
        isLoggingIn: false,
        loginInfo: null,
        user: action.data.user
      }
    case 'LOGOUT':
      return {
        ...state,
        user: null,
        isLoggingOut: false,
      }
    case 'SIGNUP':
      return {
        ...state,
        isSigningUp: false,
        signupErrors: null
      }
    case 'VERIFY_EMAIL':
      return {
        ...state,
        isVerifyingEmail: false,
        verifyEmailErrors: null
      }
    default:
      return state
  }

}

export default session
