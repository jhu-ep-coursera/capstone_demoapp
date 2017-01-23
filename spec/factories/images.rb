FactoryGirl.define do

  factory :image do
    sequence(:caption) {|n| n%2==0 ? nil : Faker::Lorem.sentence(3).chomp(".") }
    creator_id 1

    trait :with_caption do
      caption { Faker::Lorem.sentence(1).chomp(".") }
    end
  end

end
