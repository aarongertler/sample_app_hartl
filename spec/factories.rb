FactoryGirl.define do
  factory :user do    #tell FG this object is a user
    sequence(:name)   { |n| "Person #{n}"}
    sequence(:email)  { |n| "persom_#{n}@example.com"}
    password "sixchar"
    password_confirmation "sixchar"

    factory :admin do
      admin true
    end
    # FactoryGirl.create(:admin) should now work for tests
  end
end