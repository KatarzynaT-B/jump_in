require 'jump_in/strategies'
require 'jump_in/authentication/session'
require 'jump_in/authentication/cookies'

module JumpIn
  module Authentication
    include JumpIn::Authentication::Session
    include JumpIn::Authentication::Cookies

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

    def login(user:, permanent: false, expires: nil)
      if permanent
        set_cookies(user: user, expires: expires)
      else
        set_session(user: user)
      end
      true
    end

# LOGGING OUT
    def jump_out
      if session[:jump_in_id] && session[:jump_in_class]
        delete_session
      elsif cookies[:jump_in_id] && cookies[:jump_in_class]
        delete_cookies
      end
      true
    end

# HELPER METHODS
    def current_user
      return nil unless session_or_cookies_set?
      klass = (session[:jump_in_class] || cookies.signed[:jump_in_class]).constantize
      id    = (session[:jump_in_id] || cookies.signed[:jump_in_id])
      @current_user ||= klass.find_by_id(id)
    end

    def logged_in?
      !!current_user
    end

    private
    def session_or_cookies_set?
      (session[:jump_in_id] && session[:jump_in_class]) ||
      (cookies.signed[:jump_in_id] && cookies.signed[:jump_in_class])
    end

    def detected_strategy(user:, params:)
      if strategy = JumpIn::Strategies::Base::STRATEGIES.detect { |strategy| strategy.detected?(params) }
        strategy.new(user: user, params: params)
      else
        raise JumpIn::AuthenticationStrategyError
      end
    end
  end
end
