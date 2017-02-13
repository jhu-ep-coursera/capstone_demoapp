FactoryGirl.define do
  factory :image_content do
    content_type "image/jpg"
        #default to the original size when we generate just attributes
    content { File.open("db/images/sample.jpg","rb") {|f| Base64.encode64(f.read) } }
  end
end
