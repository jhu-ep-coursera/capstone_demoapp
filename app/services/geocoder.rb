class Geocoder
  def geocode address
    geoloc=Geokit::Geocoders::GoogleGeocoder.geocode address
    location(geoloc)
  end

  def reverse_geocode point
    geoloc=Geokit::Geocoders::GoogleGeocoder.reverse_geocode point.latlng
    location(geoloc)
  end

  def location geoloc
    if geoloc && geoloc.lng && geoloc.lat
      position=Point.new(geoloc.lng, geoloc.lat)
      address=PostalAddress.new(geoloc.street_address,
                      geoloc.city,
                      geoloc.state_code,
                      geoloc.zip,
                      geoloc.country_code)
      Location.new(geoloc.formatted_address, position, address)
    end
  end
end
