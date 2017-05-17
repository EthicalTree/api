import React from 'react'

import ListingDetail from './ListingDetail/ListingDetail.jsx'
import css from './ListingDetail/listing_detail.sass'

export default class App extends React.Component {

  render() {
    return (
      <div className="app">
        <ListingDetail id={"1"} />
      </div>
    )
  }
}
