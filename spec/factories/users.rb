FactoryGirl.define do

  factory :user do
    name     { Faker::Name.first_name }
    email    { Faker::Internet.email }
    password { Faker::Internet.password }
  end

  factory :admin, class: User, parent: :user do
    after(:build) do |user|
      user.roles.build(:role_name=>Role::ADMIN)
    end
  end

  factory :originator, class: User, parent: :user do
    transient do
      mname nil
    end
    after(:build) do |user, props|
      user.roles.build(:role_name=>Role::ORIGINATOR, :mname=>props.mname)
    end
  end
end
