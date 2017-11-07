require 'test_helper'

module V1
  class OperatingHoursControllerTest < ActionController::TestCase

    test 'providing an invalid listing should 404' do
      res = post :create, params: { listing_id: 'unknown', params: {} }
      assert res.status == 404
    end

    test 'owner should be able to add operating hours' do
      user = create :user
      listing = create :listing, slug: 'new-listing', owner: user

      authorize user
      res = post :create, params: { listing_id: 'new-listing', operating_hour: {
        monday: { open: '11:00am', close: '5:00pm' },
        tuesday: { open: '11:00am', close: '5:00pm' },
        wednesday: { open: '11:00am', close: '5:00pm' },
        thursday: { open: '11:00am', close: '5:00pm' },
        friday: { open: '11:00am', close: '5:00pm' }
      }}

      listing.reload
      assert res.status == 200
      assert listing.operating_hours.count == 5
    end

    test 'admin should be able to add operating hours' do
      user = create :user, admin: true
      listing = create :listing, slug: 'new-listing'

      authorize user
      res = post :create, params: { listing_id: 'new-listing', operating_hour: {
        monday: { open: '11:00am', close: '5:00pm' },
        tuesday: { open: '11:00am', close: '5:00pm' },
        wednesday: { open: '11:00am', close: '5:00pm' },
        thursday: { open: '11:00am', close: '5:00pm' },
        friday: { open: '11:00am', close: '5:00pm' }
      }}

      listing.reload
      assert res.status == 200
      assert listing.operating_hours.count == 5
    end

    test 'user should not be able to modify operating hours of someone else' do
      user = create :user
      listing = create :listing, slug: 'new-listing'

      authorize user
      res = post :create, params: { listing_id: 'new-listing', operating_hour: {
        monday: { open: '11:00am', close: '5:00pm' },
        tuesday: { open: '11:00am', close: '5:00pm' },
        wednesday: { open: '11:00am', close: '5:00pm' },
        thursday: { open: '11:00am', close: '5:00pm' },
        friday: { open: '11:00am', close: '5:00pm' }
      }}

      listing.reload
      assert res.status == 401
      assert listing.operating_hours.count == 0
    end

    test 'anonymous user should not be able to modify operating hours' do
      listing = create :listing, slug: 'new-listing'

      res = post :create, params: { listing_id: 'new-listing', operating_hour: {
        monday: { open: '11:00am', close: '5:00pm' },
        tuesday: { open: '11:00am', close: '5:00pm' },
        wednesday: { open: '11:00am', close: '5:00pm' },
        thursday: { open: '11:00am', close: '5:00pm' },
        friday: { open: '11:00am', close: '5:00pm' }
      }}

      listing.reload
      assert res.status == 401
      assert listing.operating_hours.count == 0
    end
  end
end
