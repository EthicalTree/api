import React from 'react'
import { connect } from 'react-redux'

import {
  Navbar,
  NavbarToggler,
  NavbarBrand,
  Collapse,
  Nav,
  NavItem,
  NavLink
} from 'reactstrap'

const Header = (props) => {
  const { dispatch } = props

  return (
    <div>
      <Navbar light toggleable>
        <NavbarToggler right onClick={e => { dispatch({ type: 'TOGGLE_HEADER_ACCESSIBLE' }) }} />

        <NavbarBrand href="/">
          <span className="sr-only">EthicalTree</span>
          <img className="ml-4" src="/assets/logo/logo-48x48.png" alt="EthicalTree Logo" />
        </NavbarBrand>

        <Collapse isOpen={props.header.isOpen} navbar>
          {props.loggedIn &&
            <Nav navbar className="mr-4 ml-auto">
              <NavItem>
                <NavLink
                  href="#"
                  onClick={e => { dispatch({ type: 'SET_LOGOUT_MODAL', data: true }) }}>
                  Logout
                </NavLink>
              </NavItem>
            </Nav>
          }

          {!props.loggedIn &&
            <Nav navbar className="mr-4 ml-auto">
              <NavItem>
                <NavLink
                  href="#"
                  onClick={e => { dispatch({ type: 'SET_SIGNUP_MODAL', data: true }) }}>
                  Signup
                </NavLink>
              </NavItem>

              <NavItem>
                <NavLink
                  href="#"
                  onClick={e => { dispatch({ type: 'SET_LOGIN_MODAL', data: true }) }}>
                  Login
                </NavLink>
              </NavItem>
            </Nav>
          }
        </Collapse>
      </Navbar>
    </div>
  )
}

const select = (state) => {
  return {
    session: state.session,
    header: state.header
  }
}

export default connect(select)(Header)

