# CUSTOM STRATEGIES

# In order to use this strategy you need to add it to jumpin_use:
#   jumpin_use :your_strategy_name (...)


# module JumpIn::YourStrategyName
#   def self.included(klass)
#     klass.register_jumpin_callbacks([
#       # chose only the ones you need from the following callbacks:
#       on_login:               [:your_on_login_method_name], # you can place one or more methods in the array
#       on_logout:              [:your_on_logout_method_name],
#       get_current_user:       [:your_get_current_user_method_name]
#       get_authenticated_user: [:your_get_authenticated_user_method_name])
#   end

#   def your_on_login_method_name(user:, by_cookies:nil)
#     ...
#   end

#   def your_on_logout_method_name(user:nil)
#     ...
#   end

#   def your_get_current_user_method_name
#     ...
#   end

#   def your_get_authenticated_user_method_name(user:, auth_params:)
#     return nil unless auth_params.keys == [:your_verified_arguments]
#     ...
#   end
# end
