require 'test_helper'

module V1
  class ListingsControllerTest < ActionController::TestCase

    test 'user should only be able to create listing if they have an account' do
      new_listing_params = { listing: { title: 'New Listing' } }
      res = post :create, params: new_listing_params
      assert res.status == 401

      user = create :user
      authorize user

      res = post :create, params: { listing: { title: '' } }
      assert JSON.parse(res.body)["errors"]

      res = post :create, params: new_listing_params
      assert res.status == 200
      assert Listing.last.owner.id == user.id
    end

    test 'any user should be able to see listing' do
      listing = create :listing, title: 'cool listing', bio: 'cool bio'
      res = get :show, params: { id: listing.slug }
      assert res.status == 200

      listing_json = JSON.parse(res.body)
      assert listing_json["title"] == 'cool listing'
      assert listing_json["bio"] == 'cool bio'
    end

    test 'listing that does not exist should return not found' do
      res = get :show, params: { id: 'nonexistent' }
      assert res.status == 404
    end

    test 'updating listing should perform proper validation' do
      user = create :user
      listing = create :listing, owner: user
      authorize user

      res = put :update, params: { id: listing.slug, listing: { title: '' } }
      assert JSON.parse(res.body)["errors"]

      res = put :update, params: { id: listing.slug, listing: { title: 'New Title' } }
      listing.reload
      assert listing.title == 'New Title'
    end

  end
end

