import axios from 'axios'

export const login = (data) => {
  return dispatch => {
    dispatch({ type: 'SET_LOGIN_LOADING', data: true })

    axios.post('/login', { session: data })
      .then(response => {
        if (response.data.error) {
          dispatch({ type: 'SET_LOGIN_ERROR', data: response.data.msg })
        }
        else {
          dispatch({ type: 'LOGIN', data: response.data })
        }
      })
      .catch(() => {
        dispatch({ type: 'SET_ERROR' })
      })
      .then(() => {
        dispatch({ type: 'SET_LOGIN_LOADING', data: false })
      })
  }
}

export const logout = () => {
  return dispatch => {
    dispatch({ type: 'SET_LOGOUT_LOADING', data: true })

    axios.get('/logout')
      .then(response => {
        if (response.data.error) {
          dispatch({ type: 'SET_LOGOUT_ERROR', data: response.data.msg })
        }
        else {
          dispatch({ type: 'LOGOUT' })
        }
      })
      .catch(() => {
        dispatch({ type: 'SET_ERROR' })
      })
      .then(() => {
        dispatch({ type: 'SET_LOGOUT_LOADING', data: false })
      })
  }
}

export const signup = (data) => {
  return dispatch => {
    dispatch({ type: 'SET_SIGNUP_LOADING', data: true })

    const user = {
      user: {
        email: data.email,
        password: data.password,
        password_confirmation: data.confirmPassword
      }
    }

    axios.post('/signup', user)
      .then(response => {
        if (response.data.errors) {
          dispatch({ type: 'SET_SIGNUP_ERROR', data: response.data.errors })
        }
        else {
          dispatch({ type: 'SIGNUP' })
          dispatch({ type: 'SET_VERIFYING_EMAIL_MODAL', data: true })
        }
      })
      .catch(() => {
        dispatch({ type: 'SET_ERROR' })
      })
      .then(() => {
        dispatch({ type: 'SET_SIGNUP_LOADING', data: false })
      })

  }
}

export const verifyEmail = (data) => {
  return dispatch => {
    dispatch({ type: 'SET_VERIFY_EMAIL_LOADING', data: true })

    axios.post('/confirm_email', { token: data.token })
      .then(response => {
        if (response.data.errors) {
          dispatch({ type: 'SET_VERIFY_EMAIL_ERROR', data: response.data.errors })
        }
        else {
          dispatch({ type: 'VERIFY_EMAIL' })
          dispatch({ type: 'SET_LOGIN_MODAL', data: true })
          dispatch({ type: 'SET_LOGIN_INFO', data: "Great, you're verified! Feel free to login whenever, and thanks for registering :)"})
        }
      })
      .catch(() => {
        dispatch({ type: 'SET_ERROR' })
      })
      .then(() => {
        dispatch({ type: 'SET_VERIFY_EMAIL_LOADING', data: false })
      })
  }
}
