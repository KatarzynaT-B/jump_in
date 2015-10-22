# LOGIN COUNTER

# In order to use this strategy you need to add it to jumpin_use:
#   jumpin_use :logins_counter (...)
# and add 'logins_count' column to your model, default value: 0

# require 'jump_in'

# module JumpIn
#   module LoginsCounter
#     def self.included(klass)
#       klass.register_jumpin_callbacks(
#         on_login: [:count_logins])
#     end

#     def count_logins(user:, opts:)
#       user.update_attribute('logins_count', user.logins_count + 1)
#     end
#   end
# end
