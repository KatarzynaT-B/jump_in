require 'jump_in/strategies'
require 'jump_in/authentication/session'
require 'jump_in/authentication/cookies'
require 'jump_in/authentication/login_base'

module JumpIn
  module Authentication

    include JumpIn::Strategies

    def self.included(base)
      base.send :helper_method, :current_user, :logged_in? if base.respond_to? :helper_method
    end

# LOGGING IN
    def jump_in(user:, permanent: false, expires: nil, **params)
      return false if logged_in?
      if authenticate_by_strategy(user: user, params: params)
        login(user: user, permanent: permanent, expires: expires)
      else
        return false
      end
    end

    def authenticate_by_strategy(user:, params:)
      if strategy = detected_strategy(user: user, params: params)
        strategy.authenticate_user
      else
        false
      end
    end

    def login(user:, contr: self, **login_params) # params temporary, they'll dissapear after config merge
      LoginBase::LOGINS.each { |lgn| lgn.perform_login(user: user, contr: contr, login_params: login_params) }
      true
    end

# LOGGING OUT
    def jump_out(contr: self)
      LoginBase::LOGINS.each { |lgn| lgn.perform_logout(contr: contr) }
      true
    end

# HELPER METHODS
    def current_user(contr: self)
      current_user =
        LoginBase::LOGINS.each do |lgn|
          user = lgn.current_user(contr: contr)
          break user if user
        end
    end

    def logged_in?(contr: self)
      !!current_user(contr: contr)
    end

    private
    def detected_strategy(user:, params:)
      if strategy = JumpIn::Strategies::Base::STRATEGIES.detect { |strategy| strategy.detected?(params) }
        strategy.new(user: user, params: params)
      else
        raise JumpIn::AuthenticationStrategyError
      end
    end
  end
end
