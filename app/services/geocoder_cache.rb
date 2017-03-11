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
    cache=CachedLocation.by_position(point).first
    if !cache
      geoloc = @geocoder.reverse_geocode point
      if geoloc
        cache=CachedLocation.create(:lng=>point.lng,
                                    :lat=>point.lat,
                                    :address=>geoloc.formatted_address,
                                    :location=>geoloc.to_hash)
      end
    end
    return cache && cache.valid? ? [cache.location, cache] : nil
  end
end
