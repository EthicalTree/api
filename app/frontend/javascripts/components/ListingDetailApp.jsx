import React from 'react';
import Slider from 'react-slick';
import Modal from 'react-modal';

class ImageAddModal extends React.Component {
  render() {
    return (
      <Modal />
    );
  }
}

class ListingImages extends React.Component {
  render() {
    let slides = this.props.images.map(image => {
      let style = {
        background: `url('${image.src}') no-repeat center center`,
        height: '300px'
      };

      return (
        <div
          className="listing-image"
          key={image.src}>
          <div style={style} />
        </div>
      )
    });

    return (
      <div className="listing-images">
        <Slider
          dots={false}
          infinite={true}
          slidesToShow={slides.length}>

          {slides}
        </Slider>
      </div>
    );
  }
}

class Rating extends React.Component {
  render() {
    return (
      <div className="rating">
        {this.props.value}
        <i className="fa fa-star"></i>
      </div>
    );
  }
}

class Ethicality extends React.Component {
  render() {
    let qualities = this.props.qualities.map(quality => {
      return (
        <div key={quality.name} className="quality">
          <i className="fa fa-superpowers"></i>
          <p className="name">{quality.name}</p>
        </div>
      );
    });

    return (
      <div className="ethicality">
        <h3 className="title">Ethicality</h3>
        <div className="qualities">
          {qualities}
        </div>
      </div>
    );
  }
}

class TitleBar extends React.Component {
  render() {
    return (
      <div className="title-bar">
        <h2 className="title">{this.props.title}</h2>
        <Rating value={this.props.rating} />
        <Ethicality qualities={this.props.qualities} />
      </div>
    );
  }
}

class Bio extends React.Component {
  render() {
    return (
      <div className="bio">
      </div>
    );
  }
}

class DailyHours extends React.Component {
  render() {
    return (
      <div className="daily-hours">
      </div>
    );
  }
}

class OperatingHours extends React.Component {
  render() {
    return (
      <div className="operating-hours">
      </div>
    );
  }
}

class LocationMap extends React.Component {
  render() {
    return (
      <div className="location-map">
      </div>
    );
  }
}


export default class ListingDetailApp extends React.Component {

  render() {
    let images = [{
      src: '/assets/stock/listing_default.jpg'
    }];

    let qualities = [{
      name: 'Vegetarian',
    }, {
      name: 'Vegan'
    }];

    return (
      <div className="listing-detail">
        <ListingImages images={images} />
        <TitleBar
          qualities={qualities}
          rating="4.5"
          title="Willy's Kitchen" />

        <div style={{ height: '500px' }}/>
      </div>
    );
  }

}
