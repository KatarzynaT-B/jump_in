# LAST LOGGED IN

# In order to use this strategy you need to add it to jumpin_use:
#   jumpin_use :last_logged_in (...)
# and add 'last_login' column to your model

# require 'jump_in'

# module JumpIn
#   module LastLoggedIn
#     def self.included(klass)
#       klass.register_jumpin_callbacks(
#         on_login: [:keep_last_login])
#     end

#     def keep_last_login(user:, opts:)
#       user.update_attribute('last_login', Time.now)
#     end
#   end
# end
