import React from 'react'
import { connect } from 'react-redux'

import { logout } from '../../actions/session'
import { ConfirmModal } from '../Global/Modal'

const LogoutModal = (props) => {
  const { dispatch } = props

  return (
    <ConfirmModal
      className="logout-modal small-modal"
      contentLabel="Logout"
      loading={props.session.logoutLoading}
      isOpen={props.session.isLoggingOut}
      onRequestClose={e => { dispatch({ type: 'SET_LOGOUT_MODAL', data: false }) }}
      onConfirm={e => { dispatch(logout()) }}
      msg="Are you sure you want to log out?">

    </ConfirmModal>
  )
}

const select = (state) => {
  return {
    session: state.session
  }
}

export default connect(select)(LogoutModal)
