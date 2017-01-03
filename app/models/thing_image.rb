class ThingImage < ActiveRecord::Base
  belongs_to :image
  belongs_to :thing

  validates :image, :thing, presence: true

  scope :prioritized,  -> { order(:priority=>:asc) }
  scope :things,       -> { where(:priority=>0) }
  scope :primary,      -> { where(:priority=>0).first }

  scope :with_name,    ->{ joins(:thing).select("thing_images.*, things.name as thing_name")}
  scope :with_caption, ->{ joins(:image).select("thing_images.*, images.caption as image_caption")}
end
