import React from 'react'
import Spinner from 'react-spinkit'

const Loader = (props) => {

  if (props.loading) {
    return (
      <div className="loading">
        <Spinner
          color="#526173"
          fadeIn="quarter"
          name='cube-grid'
          className="et-spinner"/>

        <div className="loading-overlay">
        </div>

        <div>
          {props.children}
        </div>
      </div>
    )
  }

  return (
    <div>
      {props.children}
    </div>
  )
}

export default Loader
