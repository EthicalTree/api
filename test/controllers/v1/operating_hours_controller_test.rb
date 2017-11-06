require 'test_helper'

module V1
  class OperatingHoursControllerTest < ActionController::TestCase

    test 'should create operating hours' do
      user = create :user
      listing = create :listing, owner: user

      res = post :create, params: { listing_id: listing.slug, operating_hour: {} }
      assert res.status == 401

      authorize user

      res = post :create, params: { listing_id: 'unknown' }
      assert res.status == 404

      res = post :create, params: { listing_id: listing.slug, operating_hour: {
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
  end
end
