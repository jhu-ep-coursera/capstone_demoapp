class ImageContent
  include Mongoid::Document
  CONTENT_TYPES=["image/jpeg","image/jpg"]
  MAX_CONTENT_SIZE=10*1000*1024

  field :image_id, type: Integer
  field :width, type: Integer
  field :height, type: Integer
  field :content_type, type: String
  field :content, type: BSON::Binary
  field :original, type: Mongoid::Boolean

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
