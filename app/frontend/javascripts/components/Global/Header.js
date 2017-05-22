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
                  onClick={e => { dispatch({ type: 'OPEN_LOGOUT_MODAL' }) }}>
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
                  onClick={e => { dispatch({ type: 'OPEN_SIGNUP_MODAL' }) }}>
                  Signup
                </NavLink>
              </NavItem>

              <NavItem>
                <NavLink
                  href="#"
                  onClick={e => { dispatch({ type: 'OPEN_LOGIN_MODAL' }) }}>
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

