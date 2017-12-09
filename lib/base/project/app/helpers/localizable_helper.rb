
module LocalizableHelper
  def prepare_coordinates(location)
    coordinate_array = location.coordinates
    coordinate_array.present? ? escape_javascript(coordinate_array.to_json).to_s : ''
  end

  def add_localization(location)
    add_localizations([location]) if location
  end

  def add_localizations(locations)
    return '' if locations.blank?

    js_locations = []
    first_location = locations.first

    been_img = image_url('map/been.png')
    current_img = image_url('map/employee.png')

    locations.each do |location|
      coordinates = prepare_coordinates(location)
      next if coordinates.blank?

      if location != first_location
        image = been_img
        current = true
      else
        image = current_img
        current = false
      end

      location_id = "loc-#{location.id}"

      js_locations << "window.map.addCoordinate({
        coordinates: #{coordinates},
        icon: '#{image}',
        locationId: '#{location_id}',
        visited: #{current},
        period: true,
        properties: { title: '#{location.name}', icon: '#{image}' }
      });"
    end

    js_locations << "window.map.getMap().setCenter(#{prepare_coordinates(first_location)});"
    js_locations << 'window.map.getMap().setZoom(15);'

    result = js_locations.join("\n")
    result.html_safe
  end
end
