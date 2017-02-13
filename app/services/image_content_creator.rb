class ImageContentCreator
  attr_accessor :image, :original, :contents

  def initialize(image, image_content=nil) 
    @image = image
    @original = image_content || @image.image_content
    @original.image_id = @image.id
    @original.original = true
    @contents = []
    @contents << @original
  end

  def build_contents sizes=nil
    sizes ||= [ImageContent::THUMBNAIL, ImageContent::SMALL,
               ImageContent::MEDIUM,    ImageContent::LARGE]
    @contents |= sizes.map { |size| build_size("#{size}") }
    self
  end

  def build_size size
    mm_image=MiniMagick::Image.read(@original.content.data)
    mm_image.format "jpg"
    mm_image.resize size
    new_contents = StringIO.new
    mm_image.write new_contents
    ImageContent.new(:image_id=>@image.id,
                     :content_type=>"image/jpg", 
                     :content=>new_contents)
  end

  def save!
    @contents.each do |content|
      next if content.persisted?
      content.save!() 
    end
    return true
  end
end
