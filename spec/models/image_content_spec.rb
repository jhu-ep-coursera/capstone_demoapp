require 'rails_helper'
require_relative '../support/image_content_helper.rb'

#Mongo::Logger.logger.level = ::Logger::DEBUG

RSpec.describe "ImageContent", type: :model do
  include_context "db_cleanup"
  include ImageContentHelper

  context "BSON::Binary" do
    it "demonstrates BSON::Binary"
    context "using helper" do
      it "derives BSON::Binary from file"
      it "derives BSON::Binary from StringIO"
      it "derives BSON::Binary from BSON::Binary"
      it "derives BSON::Binary from base64 encoded String"
    end
  end

  context "assign content" do
    it "sets content"
    it "mass-assigns content"
  end

  context "set size from JPEG" do
    it "reads EXIF from JPEG"
    it "sets size from EXIF"
    it "sets size manually"
  end

  context "valid image content" do
    it "requires image"
    it "requires content_type"
    it "requires content"
    it "requires width"
    it "requires height"
    it "requires supported content_type"
    it "checks content size maximium"
  end

  context "image content factory" do
    it "can build input attributes"
    it "encoded input content attribute with base64"
    it "can create image content"
    it "can create image contents from attributes"
  end

  context "Image has ImageContent" do
    it "has image_content"
    context "Image factory" do
      it "generates attributes with content"
      it "builds Image with content"
    end
  end

  context "Image scaling" do
    it "creates for Image with ImageContent"
    it "creates for Image and ImageContent"
  end

  
  context "content for image" do
    it "find for image"
    it "find by size"
    it "find largest"
    it "delete for image"
  end
end
