require_relative '../support/image_content_helper.rb'
FactoryGirl.define do
  factory :image_content do
    content_type "image/jpg"
        #default to the original size when we generate just attributes
    content { Base64.encode64(ImageContentHelper.sample_image_file.read) }
  end
end
