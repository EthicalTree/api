import React from 'react'
import ListingDetailApp from './components/ListingDetailApp.jsx'

export default class App extends React.Component {

  render() {
    return (
      <div className="app">
        <ListingDetailApp id={"1"} />
      </div>
    )
  }
}
