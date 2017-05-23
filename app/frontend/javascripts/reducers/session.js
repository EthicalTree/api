
const session = (state={}, action) => {

  switch (action.type) {
    case 'SET_LOGIN_MODAL':
      return {...state, isLoggingIn: action.data}
    case 'SET_LOGOUT_MODAL':
      return {...state, isLoggingOut: action.data}
    case 'SET_SIGNUP_MODAL':
      return {...state, isSigningUp: action.data}
    case 'SET_LOGIN_LOADING':
      return {...state, loginLoading: action.data}
    case 'SET_LOGOUT_LOADING':
      return {...state, logoutLoading: action.data}
    case 'SET_LOGIN_ERROR':
      return {...state, loginError: action.data}
    case 'LOGIN':
      return {
        ...state,
        ...action.data,
        loginError: false,
        isLoggingIn: false,
      }
    case 'LOGOUT':
      return {
        ...state,
        user: null,
        isLoggingOut: false
      }
    case 'SIGNUP':
      console.log('signing up')
    default:
      return state
  }

}

export default session
