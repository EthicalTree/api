require 'test_helper'

module V1
  class ListingEthicalitiesControllerTest < ActionController::TestCase

    test 'providing an invalid listing should 404' do
      res = post :create, params: { listing_id: 'unknown', params: {} }
      assert res.status == 404
    end

    test 'owner should be able to add ethicalities to listing' do
      user = create :user
      listing = create :listing, owner: user, slug: 'test-listing'
      assert listing.ethicalities.count == 0

      authorize user
      res = post :create, params: { listing_id: 'test-listing', ethicalities: [
        { slug: 'vegetarian' },
        { slug: 'fair_trade' }
      ]}

      assert res.status == 200
      listing.reload
      assert listing.ethicalities.count == 2
    end

    test 'admin should be able to add ethicalities to listing' do
      user = create :user, admin: true
      listing = create :listing, slug: 'test-listing'
      assert listing.ethicalities.count == 0

      authorize user
      res = post :create, params: { listing_id: 'test-listing', ethicalities: [
        { slug: 'vegetarian' },
        { slug: 'fair_trade' }
      ]}

      assert res.status == 200
      listing.reload
      assert listing.ethicalities.count == 2
    end

    test 'user should not be able to modify ethicalities of someone elses listing' do
      user = create :user
      listing = create :listing, slug: 'test-listing'
      assert listing.ethicalities.count == 0

      authorize user
      res = post :create, params: { listing_id: 'test-listing', ethicalities: [
        { slug: 'vegetarian' },
        { slug: 'fair_trade' }
      ]}

      assert res.status == 401
      listing.reload
      assert listing.ethicalities.count == 0
    end

    test 'anonymous user should not be able to modify ethicalities of someone elses listing' do
      listing = create :listing, slug: 'test-listing'
      assert listing.ethicalities.count == 0

      res = post :create, params: { listing_id: 'test-listing', ethicalities: [
        { slug: 'vegetarian' },
        { slug: 'fair_trade' }
      ]}

      assert res.status == 401
      listing.reload
      assert listing.ethicalities.count == 0
    end

    test 'should show ethicalities that belong to the listing' do
      listing = create :listing, slug: 'new-listing'
      listing.ethicalities = [Ethicality.find_by(slug: 'vegetarian')]
      listing.save

      res = get :index, params: { listing_id: 'new-listing' }
      assert res.status == 200
      ethicalities = JSON.parse(res.body)['ethicalities']
      assert ethicalities.length == 1

      assert ethicalities[0]['slug'] == 'vegetarian'
    end
  end
end
