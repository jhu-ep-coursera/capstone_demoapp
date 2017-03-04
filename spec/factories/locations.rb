FactoryGirl.define do
  
  factory :point do
    transient do
      lng { Faker::Number.negative(-77.0,-76.0).round(6) }
      lat { Faker::Number.positive(38.7,39.7).round(6) }
    end
    initialize_with { Point.new(lng, lat) }

    trait :jhu do
      lng -76.6200464
      lat  39.3304957
    end
  end

  factory :postal_address do
    transient do
      sequence(:street_address) {|idx| "#{3000+idx} North Charles Street"}
      city           "Baltimore"
      state_code     "MD"
      zip            "21218"
      country_code   "US"
    end
    initialize_with { PostalAddress.new(street_address,city,state_code,zip,country_code) }

    trait :jhu do
      street_address "3400 North Charles Street"
      city           "Baltimore"
      state_code     "MD"
      zip            "21218"
      country_code   "US"
    end
  end

  factory :location do
    address           { FactoryGirl.build(:postal_address) }
    position          { FactoryGirl.build(:point) }
    formatted_address { 
      street_no=address.street_address.match(/^(\d+)/)[1]
      "#{street_no} N Charles St, Baltimore, MD 21218, USA" 
    }
    initialize_with { Location.new(formatted_address,position,address) }

    trait :jhu do
      address { FactoryGirl.build(:postal_address, :jhu) }
      position { FactoryGirl.build(:point, :jhu) }
    end
  end

end
