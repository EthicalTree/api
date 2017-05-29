import React from 'react'

import {
  BrowserRouter as Router,
  Route,
  Link
} from 'react-router-dom'

import { Header, Footer } from '../Global'

import {
  LoginModal,
  LogoutModal,
  SignupModal,
  VerifyEmailModal
} from '../Session'

import ListingDetail from '../ListingDetail'
import css from './css/application.sass'

const TmpRoot = (props) => {
  return (
    <Link to="/listing/1">Test Listing!
    </Link>)
}

export default class App extends React.Component {

  constructor(props) {
    super(props)
  }

  render() {
    return (
      <div className="app">
        <Router>
          <div>
            <Header />
            <div className="container">
              <Route path="/" exact={true} component={TmpRoot} />
              <Route path="/listing/:slug" component={ListingDetail} />
            </div>
            <Footer />
            <LoginModal />
            <LogoutModal />
            <SignupModal />
            <VerifyEmailModal />
          </div>
        </Router>
      </div>
    )
  }
}
