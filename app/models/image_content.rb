class ImageContent
  include Mongoid::Document
  CONTENT_TYPES=["image/jpeg","image/jpg"]

  field :image_id, type: Integer
  field :width, type: Integer
  field :height, type: Integer
  field :content_type, type: String
  field :content, type: BSON::Binary
  field :original, type: Mongoid::Boolean

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
