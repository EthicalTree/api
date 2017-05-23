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
        dispatch({ type: 'SET_ERROR', data: 'Oops. Something went wrong!' })
      })
      .then(() => {
        dispatch({ type: 'SET_LOGIN_LOADING', data: false })
      })
  }
}
