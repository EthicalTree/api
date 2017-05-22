import { combineReducers } from 'redux'
import session from './session'
import header from './header'

const rootReducer = combineReducers({
  session,
  header
})

export default rootReducer
