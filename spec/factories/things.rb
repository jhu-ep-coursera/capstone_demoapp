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

    trait :with_roles do
      transient do
        originator_id 1
        member_id nil
      end

      after(:create) do |thing, props|
        Role.create(:role_name=>Role::ORGANIZER,
                    :mname=>Thing.name,
                    :mid=>thing.id,
                    :user_id=>props.originator_id)
        Role.create(:role_name=>Role::MEMBER,
                    :mname=>Thing.name,
                    :mid=>thing.id,
                    :user_id=>props.member_id)  if props.member_id
      end
    end
  end

end
