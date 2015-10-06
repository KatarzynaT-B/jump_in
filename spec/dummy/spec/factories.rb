FactoryGirl.define do

  factory :user_with_secure_password do
    email "email@example.com"
    password "password"
    name "User"
  end

  factory :user do
  end

  factory :user_with_token do
    token "such_a_long_token"
  end

end
