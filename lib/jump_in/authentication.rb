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

    def login(user:, **login_params) # params temporary, they'll dissapear after config merge
      self.class::ON_LOGIN.each do |on_login|
        self.send(on_login, user: user, login_params: login_params)
      end
      true
    end

# LOGGING OUT
    def jump_out
      self.class::ON_LOGOUT.each { |on_logout| self.send(on_logout) }
      true
    end

# HELPER METHODS
    def current_user
      current_user =
        self.class::GET_CURRENT_USER.each do |current_user_finder|
          user = self.send(current_user_finder)
          break user if user
        end
      current_user.is_a?(Array) ? nil : current_user
    end

    def logged_in?
      !!current_user
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
