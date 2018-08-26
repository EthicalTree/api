module LatLng
  class << self
    def parse val
      if val.match(/^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?),\s*[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$/)
        lat, lng = val.split(',')
        { lat: lat.to_f, lng: lng.to_f }
      end
    end
  end
end
