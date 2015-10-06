class UserWithToken < ActiveRecord::Base
  def authenticate(jumpin_token)
    token == jumpin_token
  end
end
