class UserWithSecurePassword < ActiveRecord::Base
  has_secure_password
end
