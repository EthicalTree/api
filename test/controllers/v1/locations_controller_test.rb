require 'test_helper'

module V1
  class LocationsControllerTest < ActionController::TestCase

    test 'providing an invalid listing should 404' do
      res = post :create, params: { listing_id: 'unknown', params: {} }
      assert res.status == 404
    end

    test 'owner should be able to add location to listing' do
      user = create :user
      listing = create :listing, owner: user, slug: 'test-listing'

      authorize user
      res = post :create, params: { listing_id: 'test-listing', location: {
        lat: 123.456,
        lng: 123.456
      }}

      assert res.status == 200
      listing.reload
      assert listing.locations.count == 1
    end

    test 'admin should be able to add location to listing' do
      user = create :user, admin: true
      listing = create :listing, slug: 'test-listing'

      authorize user
      res = post :create, params: { listing_id: 'test-listing', location: {
        lat: 123.456,
        lng: 123.456
      }}

      assert res.status == 200
      listing.reload
      assert listing.locations.count == 1
    end

    test 'user should not be able to modify location of someone elses listing' do
      user = create :user
      listing = create :listing, slug: 'test-listing'

      authorize user
      res = post :create, params: { listing_id: 'test-listing', location: {
        lat: 123.456,
        lng: 123.456
      }}

      assert res.status == 401
      listing.reload
      assert listing.locations.count == 0
    end

    test 'anonymous user should not be able to modify location of someone elses listing' do
      listing = create :listing, slug: 'test-listing'

      res = post :create, params: { listing_id: 'test-listing', location: {
        lat: 123.456,
        lng: 123.456
      }}

      assert res.status == 401
      listing.reload
      assert listing.locations.count == 0
    end
  end
end
