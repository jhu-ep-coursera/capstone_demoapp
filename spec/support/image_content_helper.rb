module ImageContentHelper
  BASE_URL="http://dev9.jhuep.com/fullstack-capstone"
  URL_PATH="db/bta/skyline.jpg"
  IMAGE_PATH="db/images/sample.jpg"


  def download_image
    image_url="#{BASE_URL}/#{URL_PATH}"
    puts "downloading #{image_url} to #{IMAGE_PATH}"
    
    FileUtils::mkdir_p(File.dirname(IMAGE_PATH))
    source=open(image_url,{ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
    IO.copy_stream(source, IMAGE_PATH)
  end

  def image_file
    unless File.file?(IMAGE_PATH)
      download_image
    end
    return File.new(IMAGE_PATH,"rb")
  end
    
end
