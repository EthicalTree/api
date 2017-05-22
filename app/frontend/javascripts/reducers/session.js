
const session = (state={}, action) => {

  switch (action.type) {
    case 'OPEN_LOGIN_MODAL':
      return {...state, isLoggingIn: true}
    case 'OPEN_LOGOUT_MODAL':
      return {...state, isLoggingOut: true}
    case 'OPEN_SIGNUP_MODAL':
      return {...state, isSigningUp: true}
    case 'CLOSE_LOGIN_MODAL':
      return {...state, isLoggingIn: false}
    case 'CLOSE_LOGOUT_MODAL':
      return {...state, isLoggingOut: false}
    case 'CLOSE_SIGNUP_MODAL':
      return {...state, isSigningUp: false}
    case 'LOGIN':
      console.log('logging in')
    case 'LOGOUT':
      console.log('logging out')
    case 'SIGNUP':
      console.log('signing up')
    default:
      return state
  }

}

export default session
