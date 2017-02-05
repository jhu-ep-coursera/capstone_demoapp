FactoryGirl.define do

  factory :image do
    sequence(:caption) {|n| n%2==0 ? nil : Faker::Lorem.sentence(3).chomp(".") }
    creator_id 1

    trait :with_caption do
      caption { Faker::Lorem.sentence(1).chomp(".") }
    end

    trait :with_roles do
      after(:create) do |image|
        Role.create(:role_name=>Role::ORGANIZER,
                    :mname=>Image.name,
                    :mid=>image.id,
                    :user_id=>image.creator_id)
      end
    end
  end

end
