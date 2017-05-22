import React from 'react'
import Slider from 'react-slick'
import Modal from 'react-modal'

import { withGoogleMap, GoogleMap, Marker } from 'react-google-maps'

import axios from 'axios'

import css from './css/listing_detail.sass'

const ImageAddModal = (props) => {
  return (
    <Modal />
  )
}

const ListingImages = (props) => {
  let slides = props.images.map(image => {
    let style = {
      background: `url('${image.src}') no-repeat center center`,
      height: '300px'
    }

    return (
      <div
        className="listing-image"
        key={image.src}>
        <div style={style} />
      </div>
    )
  })

  return (
    <div className="listing-images">
      <Slider
        dots={false}
        infinite={true}
        slidesToShow={slides.length}>

        {slides}
      </Slider>
    </div>
  )
}

const Rating = (props) => {
  return (
    <div className="rating">
      {props.value}
      <i className="fa fa-star"></i>
    </div>
  )
}

const TitleBar = (props) => {
  return (
    <div className="title-bar">
      <h2 className="title">{props.title}</h2>
      <Rating value={props.rating} />
    </div>
  )
}

const Ethicality = (props) => {

  let ethicalities = props.ethicalities.map(quality => {
    return (
      <div key={quality.name} className="quality">
        <i className="fa fa-superpowers"></i>
        <p className="name">{quality.name}</p>
      </div>
    )
  })

  return (
    <div className="ethicality">
      <h3 className="title">Ethicality</h3>
      <div className="ethicalities">
        {ethicalities}
      </div>
    </div>
  )

}

const DailyHours = (props) => {
  return (
    <div className="daily-hours">
      <p>{props.day}</p>
      <p>{props.hours}</p>
    </div>
  )
}

const OperatingHours = (props) => {
  let hours = props.hours.map(hours => {
    return (
      <DailyHours key={hours.day} day={hours.day} hours={hours.hours} />
    )
  })

  return (
    <div className="operating-hours">
      <h3 className="title">Operating Hours</h3>
      {hours}
    </div>
  )
}


const AsideInfo = (props) => {
  return (
    <aside>
      <Ethicality ethicalities={props.ethicalities} />
      <OperatingHours hours={props.hours} />
    </aside>
  )
}

const Bio = (props) => {
  return (
    <div className="bio">
      <h3>About {props.title}</h3>
      <p>{props.bio}</p>
    </div>
  )
}

const Map = withGoogleMap(props => {

  let bounds = new google.maps.LatLngBounds()

  let markers = props.locations.map(l => {
    bounds.extend(l)

    return (
      <Marker key={`${l.lat}+${l.lng}`} position={l} />
    )
  })

  let onLoad = (map) => {
    if (map) {
      map.fitBounds(bounds)
    }
  }

  return (
    <GoogleMap
      ref={onLoad}
      defaultZoom={12}
      defaultCenter={props.locations[0]}
      defaultOptions={{
        scrollwheel: false
      }}>

      {markers}

    </GoogleMap>
  )
})

const ListingMap = props => {

  return (
    <div className="listing-map">
      <h3>How to get here</h3>
      <div className="listing-map-area">
        <Map
          locations={props.locations}
          containerElement={
            <div style={{ height: `100%` }} />
          }
          mapElement={
            <div style={{ height: `100%` }} />
          }/>
      </div>
    </div>
  )

}

const ListingInfo = (props) => {
  return (
    <div className="listing-info">
      <Bio
        title={props.title}
        bio={props.bio} />

      <ListingMap
        locations={props.locations}
        />
    </div>
  )
}

export default class ListingDetail extends React.Component {

  constructor(props) {
    super(props)

    let images = [{
      src: '/assets/stock/listing_default.jpg'
    }]

    let ethicalities = [{
      name: 'Vegetarian',
    }, {
      name: 'Vegan'
    }]

    let title = "Willy's Kitchen"
    let bio = "At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat"

    let hours = [{
      day: 'Monday',
      hours: '12pm - 2pm'
    }, {
      day: 'Tuesday',
      hours: '12pm - 5pm'
    }]

    let rating = "4.3"

    let locations = [{
      lat: 45.391,
      lng: -75.754
    }, {
      lat: 45.394,
      lng: -75.749
    }]

    this.state = {
      images: images,
      ethicalities: ethicalities,
      title: title,
      bio: bio,
      hours: hours,
      rating: rating,
      locations: locations
    }

    //this.fetchListing()
  }

  fetchListing() {
    axios.get(`/listings/${this.props.mathc.slug}`).then(listing => {
      this.setState(listing.data)
    })
  }

  render() {
    return (
      <div className="listing-detail">
        <ListingImages images={this.state.images} />
        <TitleBar
          rating={this.state.rating}
          title={this.state.title} />

        <AsideInfo
          ethicalities={this.state.ethicalities}
          hours={this.state.hours}/>

        <ListingInfo
          locations={this.state.locations}
          bio={this.state.bio}
          title={this.state.title} />
      </div>
    )
  }

}
