class Point
  attr_accessor :lng, :lat

  def initialize(lng, lat)
    @lng = lng
    @lat = lat
  end

  def ==(rhs) 
    !rhs ? false : (lng==rhs.lng && lat==rhs.lat)
  end

  def ===(rhs) 
    !rhs ? false : rnd(lng)==rnd(rhs.lng) && rnd(lat)==rnd(rhs.lat)
  end

  def rnd(value) 
    !value ? nil : value.round(2)
  end

  def lnglat
    [@lng,@lat]
  end

  def latlng
    [@lat,@lng]
  end

  def to_hash
    { lng: @lng, lat: @lat }
  end
end
