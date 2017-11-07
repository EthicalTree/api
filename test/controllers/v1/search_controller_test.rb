require 'test_helper'

module V1
  class SearchControllerTest < ActionController::TestCase

    def setup
      20.times do |i|
        location = build :location
        create :listing, slug: "test-listing-#{i}", locations: [location]
      end
    end

    test 'search with empty string should still return results' do
      res = get :search, params: { query: '', page: 0, ethicalities: '' }
      listings = JSON.parse(res.body)
      assert listings['listings'].count > 0
      assert listings['listings'].count < 20
    end

    test 'search with query and no ethicalities should order by string match in title' do

    end

    test 'search with ethicalities should first prioritize ethicality match, and then search query' do

    end

    test 'pagination should return the correct page' do

    end

  end
end
