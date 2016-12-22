FactoryGirl.define do

  factory :foo_fixed, class: 'Foo' do
    name "test" 
  end

  factory :foo, :parent=>:foo_fixed do
  end
end
