module Base::Project::App::Models::Concerns::Localizable
  extend ActiveSupport::Concern

  included do
    scope :by_coord, ->(latitude, longitude) { near(latitude, longitude, 1) }

    scope :near, ->(lat, lng, radius) {
      d = ->(b) { destination_point(lat, lng, b, radius) }

      where(['latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ?', d[180][:lat],
             d[0][:lat],
             d[270][:lng],
             d[90][:lng]])
        .where(['COALESCE(DISTANCE(?, ?, latitude, longitude), 0) < ?', lat, lng, radius])
        .order(:id)
    }
  end

  def coordinates
    [longitude, latitude] if latitude && longitude
  end

  module ClassMethods
    # Return destination point given distance and bearing from start point
    def destination_point(lat, lng, initial_bearing, distance)
      d2r = ->(x) { x * Math::PI / 180 }
      r2d = ->(x) { x * 180 / Math::PI }

      lat ||= 0
      lng ||= 0

      angular_distance = distance / 6371.0

      lat1 = d2r.call(lat)
      lng1 = d2r.call(lng)
      bearing = d2r.call(initial_bearing)

      lat2 = Math.asin(Math.sin(lat1) *
                       Math.cos(angular_distance) +
                       Math.cos(lat1)             *
                       Math.sin(angular_distance) *
                       Math.cos(bearing))

      lng2 = lng1 + Math.atan2(Math.sin(bearing) * Math.sin(angular_distance) * Math.cos(lat1),
                               Math.cos(angular_distance) - Math.sin(lat1) * Math.sin(lat2))

      { lat: r2d.call(lat2).round(7), lng: r2d.call(lng2).round(7) }
    end
  end
end
