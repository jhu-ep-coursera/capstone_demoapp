FactoryGirl.define do

  factory :thing do
    name { Faker::Commerce.product_name }
    sequence(:description) {|n| n%5==0 ? nil : Faker::Lorem.paragraphs.join}
    sequence(:notes) {|n| n%5<2 ? nil : Faker::Lorem.paragraphs.join}
  end

end
