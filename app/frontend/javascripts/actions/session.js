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
        //cdispatch({ type: 'SET_LOGOUT_LOADING', data: false })
      })
  }
}
