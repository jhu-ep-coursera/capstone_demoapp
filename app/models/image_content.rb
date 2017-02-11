class ImageContent
  include Mongoid::Document
  field :image_id, type: Integer
  field :width, type: Integer
  field :height, type: Integer
  field :content_type, type: String
  field :content, type: BSON::Binary
  field :original, type: Mongoid::Boolean

  def content=(value)
    self[:content]=self.class.to_binary(value)
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
end
