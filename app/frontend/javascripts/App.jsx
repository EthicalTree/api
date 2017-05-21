import React from 'react'
import {
  BrowserRouter as Router,
  Route
} from 'react-router-dom'

import ListingDetail from './ListingDetail/ListingDetail.jsx'
import css from './ListingDetail/listing_detail.sass'

export default class App extends React.Component {

  render() {
    return (
      <div className="app">
        <Router>
          <Route path="/listing/:slug" component={ListingDetail} />
        </Router>
      </div>
    )
  }
}
