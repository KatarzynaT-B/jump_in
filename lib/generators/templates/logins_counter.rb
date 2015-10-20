# LOGIN COUNTER

# In order to use this strategy you need to add it to jumpin_use:
#   jumpin_use :login_counter (...)
# and add 'logins_count' column to your model

# module JumpIn::LoginsCounter
#   def self.included(klass)
#     klass.register_jumpin_callbacks(
#       on_login: [:count_logins])
#   end

#   def count_logins(user:, by_cookies:nil)
#     user.update_attribute('logins_count', user.logins_count + 1)
#   end
# end
