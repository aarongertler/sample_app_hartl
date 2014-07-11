FactoryGirl.define do
  factory :user do    #tell FG this object is a user
    name  "Aaron Gertler"
    email "me@aarongertler.net"
    password "sixchar"
    password_confirmation "sixchar"
  end
end