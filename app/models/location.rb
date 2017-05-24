class Location
  attr_accessor :formatted_address, :position, :address

  def initialize(formatted_address=nil, position=nil, address=nil)
    @formatted_address=formatted_address
    @position=position
    @address=address
  end

  def ==(rhs) 
    !rhs ? false : (formatted_address==rhs.formatted_address && 
                    position===rhs.position &&
                    address==address)
  end

  def ===(rhs) 
    !rhs ? false : ((formatted_address=~/#{rhs.formatted_address}/ || /#{formatted_address}/.match(rhs.formatted_address)) && 
                    position===rhs.position &&
                    address==address)
  end

  def to_hash 
    hash= {}
    hash[:formatted_address] = @formatted_address if @formatted_address
    hash[:position] = @position.to_hash     if @position
    hash[:address]  = @address.to_hash      if @address
    hash
  end
end
