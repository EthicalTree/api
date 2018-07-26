# frozen_string_literal: true

ipstack_key = Rails.application.secrets[:ipstack_api_key]
gmaps_key = Rails.application.secrets[:gmaps_api_key]

Geocoder.configure(lookup: :google, api_key: gmaps_key)
