import React from 'react'
import { BrowserRouter as Router, Route } from 'react-router-dom'

import { Header, Footer } from '../Global'

import {
  LoginModal,
  LogoutModal,
  SignupModal,
  VerifyEmailModal
} from '../Session'

import ListingDetail from '../ListingDetail'
import css from './css/application.sass'

export default class App extends React.Component {

  constructor(props) {
    super(props)
  }

  render() {
    return (
      <div className="app">
        <Header />
        <div className="container">
          <Router>
            <Route path="/listing/:slug" component={ListingDetail} />
          </Router>
        </div>
        <Footer />
        <LoginModal />
        <LogoutModal />
        <SignupModal />
        <VerifyEmailModal />
      </div>
    )
  }
}
