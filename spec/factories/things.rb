FactoryGirl.define do

  factory :thing do
    name { Faker::Commerce.product_name }
    sequence(:description) {|n| n%5==0 ? nil : Faker::Lorem.paragraphs.join}
    sequence(:notes) {|n| n%5<2 ? nil : Faker::Lorem.paragraphs.join}

    trait :with_image do
      transient do
        image_count 1
      end
      after(:build) do |thing, props|
        thing.thing_images << build_list(:thing_image, props.image_count, :thing=>thing)
      end
    end

    trait :with_fields do
      description { Faker::Lorem.paragraphs.join }
      notes       { Faker::Lorem.paragraphs.join }
    end
  end

end
