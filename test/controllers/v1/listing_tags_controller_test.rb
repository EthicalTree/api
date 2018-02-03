require 'test_helper'

module V1
  class ListingTagsControllerTest < ActionController::TestCase

    test 'providing an invalid listing should 404' do
      res = post :create, params: { listing_id: 'unknown', params: {} }
      assert res.status == 404
    end

    test 'owner should be able to add ethicalities to listing' do
      user = create :user
      listing = create :listing, owner: user, slug: 'test-listing'
      assert listing.tags.count == 0

      authorize user
      res = post :create, params: {
        listing_id: 'test-listing',
        tag: { hashtag: '#neat' }
      }

      assert res.status == 200
      listing.reload
      assert listing.tags.count == 1
    end

    test 'admin should be able to add ethicalities to listing' do
      user = create :user, admin: true
      listing = create :listing, slug: 'test-listing'
      assert listing.tags.count == 0

      authorize user
      res = post :create, params: {
        listing_id: 'test-listing',
        tag: { hashtag: '#wow' }
      }

      assert res.status == 200
      listing.reload
      assert listing.tags.count == 1
    end
  end
end
