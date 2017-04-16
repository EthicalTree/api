import React from 'react';
import Slider from 'react-slick';
import Modal from 'react-modal';
import GoogleMap from 'google-map-react';

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

class TitleBar extends React.Component {
  render() {
    return (
      <div className="title-bar">
        <h2 className="title">{this.props.title}</h2>
        <Rating value={this.props.rating} />
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

class DailyHours extends React.Component {
  render() {
    return (
      <div className="daily-hours">
        <p>{this.props.day}</p>
        <p>{this.props.hours}</p>
      </div>
    );
  }
}

class OperatingHours extends React.Component {
  render() {
    let hours = this.props.hours.map(hours => {
      return (
        <DailyHours key={hours.day} day={hours.day} hours={hours.hours} />
      );
    });

    return (
      <div className="operating-hours">
        <h3 className="title">Operating Hours</h3>
        {hours}
      </div>
    );
  }
}


class AsideInfo extends React.Component {
  render() {
    return (
      <aside>
        <Ethicality qualities={this.props.qualities} />
        <OperatingHours hours={this.props.hours} />
      </aside>
    );
  }
}

class Bio extends React.Component {
  render() {
    return (
      <div className="bio">
        <h3>About {this.props.title}</h3>
        <p>{this.props.bio}</p>
      </div>
    );
  }
}

class ListingMap extends React.Component {
  render() {
    let center = { lat: -34.397, lng: 150.644 };

    return (
      <div className="listing-map">
        <h3>How to get here</h3>
        <div className="listing-map-area">
          <GoogleMap
            bootstrapURLKeys={{ key: window.ET.keys.gmaps_api_key }}
            defaultZoom={8}
            defaultCenter={center}>
          </GoogleMap>
        </div>
      </div>
    );
  }
}

class ListingInfo extends React.Component {
  render() {
    return (
      <div className="listing-info">
        <Bio
          title={this.props.title}
          bio={this.props.bio} />

        <ListingMap/>
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

    let title = "Willy's Kitchen";
    let bio = "At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat";

    let hours = [{
      day: 'Monday',
      hours: '12pm - 2pm'
    }, {
      day: 'Tuesday',
      hours: '12pm - 5pm'
    }];

    return (
      <div className="listing-detail">
        <ListingImages images={images} />
        <TitleBar
          rating="4.5"
          title={title} />

        <AsideInfo
          qualities={qualities}
          hours={hours}
          />

        <ListingInfo
          bio={bio}
          title={title} />
        <div style={{ height: '500px' }}/>
      </div>
    );
  }

}
