class PostalAddress
  attr_accessor :street_address, :city, :state_code, :zip, :country_code

  def initialize(street=nil, city=nil, state_code=nil, zip=nil, country_code=nil)
    @street_address=street
    @city=city
    @state_code=state_code
    @zip=zip
    @country_code=country_code
  end


  def ==(rhs) 
    !rhs ? false : (street_address==rhs.street_address && 
                    city==rhs.city &&
                    state_code==rhs.state_code &&
                    zip==rhs.zip &&
                    country_code==rhs.country_code)
  end

  def to_hash
    { 
      street_address: @street_address,
      city: @city,
      state_code: @state_code,
      zip: @zip,
      country_code: @country_code,
    }
  end

  def full_address
    if @street_address || @city || @state_code || @zip || @country_code
      parts=[]
      parts << @street_address          if @street_address
      parts << @city                    if @city
      parts << "#{state_code} #{@zip}"  if @state_code || @zip
      parts << @country_code            if @country_code
      parts.join(", ").squeeze(" ")
    end
  end
  def to_s
    full_address
  end
end
