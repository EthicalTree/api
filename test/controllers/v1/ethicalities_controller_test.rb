require 'test_helper'

module V1
  class EthicalitiesControllerTest < ActionController::TestCase

    test 'should show all available ethicalities' do
      res = get :index
      ethicalities = JSON.parse(res.body)
      assert ethicalities.count == Ethicality.count
    end

  end
end
