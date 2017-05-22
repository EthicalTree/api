import axios from 'axios'

export const login = (data) => {
  return dispatch => {
    dispatch({ type: 'SET_LOGIN_LOADING', data: true })

    axios.post('/login', { session: data })
      .then(response => {

        dispatch({ type: 'SET_LOGIN_LOADING', data: false })
        dispatch({ type: 'LOGIN' })

      })
      .fail(() => {

        dispatch({ type: 'SET_ERROR', data: 'Oops. Something went wrong!' })

      })
  }
}
