class ImageContent
  include Mongoid::Document
  #3:2 ratios
  THUMBNAIL="100x67"
  SMALL="320x213"
  MEDIUM="800x533"
  LARGE="1200x800"
  CONTENT_TYPES=["image/jpeg","image/jpg"]
  MAX_CONTENT_SIZE=10*1000*1024

  field :image_id, type: Integer
  field :width, type: Integer
  field :height, type: Integer
  field :content_type, type: String
  field :content, type: BSON::Binary
  field :original, type: Mongoid::Boolean

  index({image_id:1, width:1, height:1}, {name: "fdx_image_size"})

  validates_presence_of :image_id, :height, :width, :content_type, :content
  validate :validate_width_height, :validate_content_length

  def validate_width_height
    if (!width || !height) && content
      unless CONTENT_TYPES.include? content_type
        errors.add(:content_type,"[#{content_type}] not supported type #{CONTENT_TYPES}")
      end
    end
  end
  def validate_content_length
    if (content && content.data.size > MAX_CONTENT_SIZE)
      errors.add(:content,"#{content.data.size} too large, greater than max #{MAX_CONTENT_SIZE}")
    end
  end

  scope :image, ->(image) { where(:image_id=>image.id) if image }
  scope :smallest, ->(min_width=nil, min_height=nil) { 
    if min_width || min_height
      query=where({})
      query=query.where(:width=>{:$gte=>min_width})   if min_width
      query=query.where(:height=>{:$gte=>min_height}) if min_height
      query.order(:width.asc, :height.asc).limit(1) 
    else 
      order(:width.desc, :height.desc).limit(1) 
    end
  }

  def content=(value)
    if self[:content]
      self.width = nil
      self.height = nil
    end
    self[:content]=self.class.to_binary(value)
    exif.tap do |xf|
      self.width = xf.width   if xf
      self.height = xf.height if xf
    end
  end

  def suffix
    "jpg" if CONTENT_TYPES.include? content_type
  end

  def self.to_binary(value)
    case
    when value.is_a?(IO) || value.is_a?(StringIO)
      value.rewind
      BSON::Binary.new(value.read)
    when value.is_a?(BSON::Binary)
      value
    when value.is_a?(String)
      decoded=Base64.decode64(value)
      BSON::Binary.new(decoded)
    end
  end

  def exif
    if content
      case
      when (CONTENT_TYPES.include? content_type)
        EXIFR::JPEG.new(StringIO.new(content.data))
      end
    end
  end
end
