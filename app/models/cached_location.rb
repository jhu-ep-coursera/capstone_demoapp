class CachedLocation
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  store_in collection: "locations"

  field :address, type: String
  field :lng, type: Float
  field :lat, type: Float
  field :location, type: Hash

  validates :address, presence: true, length: {minimum: 3}
  validates :lng, presence: true
  validates :lat, presence: true

  index({address:1},    
        {name: "idx_loc_address",
         expire_after_seconds: 86400})
  index({lng:1, lat:1}, 
        {name: "idx_loc_position",
         expire_after_seconds: 86400})

  scope :by_address, ->(addr)  { where(:address=>normalize(addr)) }
  scope :by_position,->(point) { where(:lng=>round(point.lng),:lat=>round(point.lat)) }

  def address=(value) 
    self[:address]=self.class.normalize(value)
  end
  def lng=(value)
    self[:lng]=self.class.round(value)
  end
  def lat=(value)
    self[:lat]=self.class.round(value)
  end

  def self.normalize(name)
    name.downcase.delete(" ,")  if name
  end
  def self.round(f) 
    f.round(5)  if f
  end
end
