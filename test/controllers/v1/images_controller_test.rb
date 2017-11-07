require 'test_helper'

module V1
  class ImagesControllerTest < ActionController::TestCase
    def setup

    end

    test 'providing an invalid listing should 404' do
      res = post :create, params: { listing_id: 'unknown', params: {} }
      assert res.status == 404
    end

    test 'owner should be able to add image to listing' do
      user = create :user
      listing = create :listing, owner: user, slug: 'test-listing'

      authorize user
      res = post :create, params: { listing_id: 'test-listing', image: {
        key: 'test-key'
      }}

      assert res.status == 200
      listing.reload
      assert listing.images.count == 1
    end

    test 'admin should be able to add image to listing' do
      user = create :user, admin: true
      listing = create :listing, slug: 'test-listing'

      authorize user
      res = post :create, params: { listing_id: 'test-listing', image: {
        key: 'test-key'
      }}

      assert res.status == 200
      listing.reload
      assert listing.images.count == 1
    end

    test 'user should not be able to modify image of someone elses listing' do
      user = create :user
      listing = create :listing, slug: 'test-listing'

      authorize user
      res = post :create, params: { listing_id: 'test-listing', image: {
        key: 'test-key'
      }}

      assert res.status == 401
      listing.reload
      assert listing.images.count == 0
    end

    test 'anonymous user should not be able to modify image of someone elses listing' do
      listing = create :listing, slug: 'test-listing'

      res = post :create, params: { listing_id: 'test-listing', image: {
        key: 'test-key'
      }}

      assert res.status == 401
      listing.reload
      assert listing.images.count == 0
    end

    test 'deleting image should remove it from the listing' do
      user = create :user
      image = create :image, id: 1
      listing = create :listing, owner: user, images: [image], slug: 'test-listing'
      assert listing.images.count == 1

      authorize user
      res = delete :destroy, params: { listing_id: 'test-listing', id: 1 }

      assert res.status == 200
      listing.reload
      assert listing.images.count == 0
    end

    test 'making an image a cover photo should return it as the first image' do
      user = create :user, admin: true
      image1 = create :image, id: 1, order: 1
      image2 = create :image, id: 2, order: 2
      listing = create :listing, images: [image1, image2], slug: 'test-listing'

      assert listing.as_json_full['images'][0]['id'] == 1
      assert listing.as_json_full['images'][1]['id'] == 2

      authorize user
      res = put :update, params: { listing_id: 'test-listing', id: 2, make_cover: true }

      assert res.status == 200
      listing.reload
      assert listing.as_json_full['images'][0]['id'] == 2
      assert listing.as_json_full['images'][1]['id'] == 1
    end
  end
end
