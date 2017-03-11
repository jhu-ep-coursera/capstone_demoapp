class GeocoderCache
  def initialize(geocoder)
    @geocoder = geocoder
  end

  def geocode address
    cache=CachedLocation.by_address(address).first
    if !cache
      geoloc = @geocoder.geocode address
      if geoloc
        cache=CachedLocation.create(:lng=>geoloc.position.lng,
                                    :lat=>geoloc.position.lat,
                                    :address=>address,
                                    :location=>geoloc.to_hash)
      end
    end
    return cache && cache.valid? ? [cache.location, cache] : nil
  end

  def reverse_geocode point
  end
end
