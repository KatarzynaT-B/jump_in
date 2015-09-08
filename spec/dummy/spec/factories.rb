FactoryGirl.define do

  factory :user_with_secure_password do
    email "email@example.com"
    password "password"
    name "User"
  end

end
