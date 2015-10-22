# LAST LOGGED OUT

# In order to use this strategy you need to add it to jumpin_use:
#   jumpin_use :last_logged_out (...)
# and add 'last_logout' column to your model

# module JumpIn::LastLoggedOut
#   def self.included(klass)
#     klass.register_jumpin_callbacks(
#       on_logout: [:keep_last_logout])
#   end

#   def keep_last_logout(opts:)
#     user = opts[:user]
#     user.update_attribute('last_logout', Time.now)
#   end
# end
