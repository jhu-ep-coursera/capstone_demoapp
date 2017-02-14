require 'rails_helper'
require_relative '../support/image_content_helper.rb'

#Mongo::Logger.logger.level = ::Logger::DEBUG

RSpec.describe "ImageContent", type: :model do
  include_context "db_cleanup"
  include ImageContentHelper
  let(:fin) { image_file }

  context "BSON::Binary" do
    it "demonstrates BSON::Binary" do
      binary=BSON::Binary.new(fin.read)
      expect(binary.data.size).to eq(fin.size)

      fout=File.open("tmp/out.jpg", "wb")
      fout.write(binary.data)
      expect(fout.size).to eq(fin.size)
      fout.close
    end

    context "using helper" do
      it "derives BSON::Binary from file" do
        binary=ImageContent.to_binary(fin)
        expect(binary.class).to be(BSON::Binary)
        expect(binary.data.size).to eq(fin.size)
      end
      it "derives BSON::Binary from StringIO" do
        strio=StringIO.new(fin.read)
        binary=ImageContent.to_binary(strio)
        expect(binary.class).to be(BSON::Binary)
        expect(binary.data.size).to eq(fin.size)
      end
      it "derives BSON::Binary from BSON::Binary" do
        binary=BSON::Binary.new(fin.read)
        binary=ImageContent.to_binary(binary)
        expect(binary.class).to be(BSON::Binary)
        expect(binary.data.size).to eq(fin.size)
      end
      it "derives BSON::Binary from base64 encoded String" do
        content=BSON::Binary.new(fin.read)
        b64=Base64.encode64(content.data)
        binary=ImageContent.to_binary(b64)
        expect(binary.class).to be(BSON::Binary)
        expect(binary.data.size).to eq(fin.size)
      end
    end
  end

  context "assign content" do
    it "sets content" do
      strio=StringIO.new(fin.read)
      ic=ImageContent.new
      ic.content=strio
      expect(ic.content.class).to be(BSON::Binary)
      expect(ic.content.data.size).to eq(fin.size)
    end
    it "mass-assigns content" do
      strio=StringIO.new(fin.read)
      ic=ImageContent.new(:content=>strio)
      expect(ic.content.class).to be(BSON::Binary)
      expect(ic.content.data.size).to eq(fin.size)
    end
  end

  context "set size from JPEG" do
    let(:ic) {ImageContent.new(:content_type=>"image/jpg",:content=>fin)}

    it "reads EXIF from JPEG" do
      expect(exif=ic.exif).to_not be_nil
      expect(exif.width).to_not be_nil
      expect(exif.height).to_not be_nil
    end
    it "sets size from EXIF" do
      expect(ic.width).to eq(ic.exif.width)
      expect(ic.height).to eq(ic.exif.height)
    end
    it "sets size manually" do
      width=666; height=444
      ic=ImageContent.new(
        width:width,
        height:height,
        content_type:"image/png", 
        content:fin)
      expect(ic.width).to eq(width)
      expect(ic.height).to eq(height)
    end
  end

  context "valid image content" do
    let(:ic) {ImageContent.new(:image_id=>1,:content_type=>"image/jpg",:content=>fin)}
    before(:each) do
      expect(ic.validate).to be true
      expect(ic.errors.messages).to be_empty
    end

    it "requires image" do
      ic.image_id=nil
      expect(ic.validate).to be false
      expect(ic.errors.messages).to include(:image_id)
      #pp ic.errors.messages
    end
    it "requires content_type" do
      ic.content_type=nil
      expect(ic.validate).to be false
      expect(ic.errors.messages).to include(:content_type)
    end
    it "requires content" do
      ic.content=nil
      expect(ic.validate).to be false
      expect(ic.errors.messages).to include(:content)
    end
    it "requires width" do
      ic.width=nil
      expect(ic.validate).to be false
      expect(ic.errors.messages).to include(:width)
    end
    it "requires height" do
      ic.height=nil
      expect(ic.validate).to be false
      expect(ic.errors.messages).to include(:height)
    end
    it "requires supported content_type" do
      ic.content_type="image/png"
      ic.content=ic.content
      expect(ic.validate).to be false
      expect(ic.errors.messages).to include(:content_type)
      expect(ic.errors.messages[:content_type]).to include(/png/)
      #pp ic.errors.messages
    end
    it "checks content size maximium" do
      content=""
      decoded_pad = ic.content.data
      begin
        content += decoded_pad
      end while content.size < ImageContent::MAX_CONTENT_SIZE
      ic.content=Base64.encode64(content)

      expect(ic.validate).to be false
      expect(ic.errors.messages).to include(:content)
      #pp ic.errors.messages
    end
  end

  context "ImageContent factory" do
    include_context "db_scope"

    it "can build input attributes" do
      props=FactoryGirl.attributes_for(:image_content)
      expect(props).to include(:content_type=>"image/jpg")
      expect(props).to include(:content)
    end
    it "encoded input content attribute with base64" do
      props=FactoryGirl.attributes_for(:image_content)
      data=Base64.decode64(props[:content])
      binary=ImageContent.to_binary(props[:content])
      expect(data.size).to eq(binary.data.size)
      expect(data).to eq(binary.data)
    end
    it "can create image content" do
      image=Image.create(creator_id:1)
      ic=FactoryGirl.create(:image_content, image_id:image.id)
      expect(ic).to be_valid
      expect(ic.image_id).to eq(image.id)
    end
    it "can create image contents from attributes" do
      image=Image.create(creator_id:1)
      props=FactoryGirl.attributes_for(:image_content)
      ic=ImageContent.create(props.merge(image_id:image.id))
      expect(ic).to be_valid
    end
  end

  context "Image has ImageContent" do
    it "has image_content" do
      expect(Image.new).to respond_to(:image_content)
    end
    context "Image factory" do
      it "generates attributes with content" do
        props=FactoryGirl.attributes_for(:image)
        expect(props).to include(:image_content)
        expect(props[:image_content].class).to eq(Hash)
        expect(props[:image_content]).to include(:content_type,:content)
        expect(props[:image_content][:content_type]).to eq("image/jpg")
      end
      it "builds Image with content" do
        image=FactoryGirl.build(:image)
        expect(image.image_content).to_not be_nil
        expect(image.image_content.class).to eq(ImageContent)
        expect(image.image_content.width).to_not be_nil
        expect(image.image_content.height).to_not be_nil
        expect(image.image_content.content_type).to eq("image/jpg")
      end
    end
  end

  context "Image scaling" do
    include_context "db_scope"
    let(:image)         { FactoryGirl.build(:image) }
    let(:image_content) { FactoryGirl.build(:image_content) }
    before(:each) do 
      expect(defined? ImageContentCreator).to eq("constant")
      image.save   #generate an ID for image w/o saving content
    end
    after(:each) do
      expect(ImageContent.image(image).count).to eq(5)
      expect(ImageContent.image(image).where(:original=>true).count).to eq(1)
      expect(ImageContent.image(image).not.where(:original=>true).count).to eq(4)
    end

    it "creates for Image with ImageContent" do
      creator=ImageContentCreator.new(image)
      creator.build_contents
      expect(creator.save!).to eq true
    end
    it "creates for Image and ImageContent" do
      image.image_content = nil
      creator=ImageContentCreator.new(image, image_content)
      creator.build_contents
      expect(creator.save!).to eq true
    end
  end

  context "content for image" do
    include_context "db_scope"
    let(:image) { FactoryGirl.create(:image) }

    it "find for image" do
      expect(ImageContent.image(image).count).to eq(5)
    end
    it "find by size" do
      ic=ImageContent.image(image).smallest(150)
      expect(ic.to_a.size).to eq(1)
      expect(ic.first.width).to be >= 150
      ic=ImageContent.image(image).smallest(800).first
      expect(ic.width).to be >= 800
      ic=ImageContent.image(image).smallest(nil, 600).first
      expect(ic.height).to be >= 600
      ic=ImageContent.image(image).smallest(150, 600).first
      expect(ic.height).to be >= 600
      ic=ImageContent.image(image).smallest(1200, 600).first
      expect(ic.width).to be >= 1200
      expect(ImageContent.image(image).smallest(2000, 2000).to_a.count).to eq(0)
    end
    it "find largest" do
      ic=ImageContent.image(image).smallest
      expect(ic.to_a.count).to eq(1)
      ic=ic.first
      widest=ImageContent.image(image).order(:width.desc).limit(1).first
      expect(ic.id).to eq(widest.id)
      tallest=ImageContent.image(image).order(:height.desc).limit(1).first
      expect(ic.id).to eq(tallest.id)
    end
    it "delete for image" do
      image  #touch to insert into DB
      image2=FactoryGirl.create(:image)
      expect(ImageContent.count).to eq(10)
      expect(ImageContent.image(image).count).to eq(5)
      ImageContent.image(image).delete_all
      expect(ImageContent.image(image).count).to eq(0)
      expect(ImageContent.count).to eq(5)
    end
  end
end
