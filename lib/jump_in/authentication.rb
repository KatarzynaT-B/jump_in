require 'jump_in/strategies'
require 'jump_in/persistence'

module JumpIn
  module Authentication
    def self.included(base)
      base.extend(ClassMethods)
      base.send :helper_method, :current_user, :logged_in? if
        base.respond_to? :helper_method
      base.const_set('GET_CURRENT_USER', [])
      const_set('APP_MAIN_CONTROLLER', base)
    end

    # LOGGING IN
    def jump_in(user:, **auth_params)
      if !logged_in? && authenticate_by_strategy(user: user,
                                                 auth_params: auth_params)
        login(user: user)
      else
        return false
      end
    end

    def authenticate_by_strategy(user:, auth_params:)
      if strategy = detected_strategy(user: user, auth_params: auth_params)
        strategy.authenticate_user
      else
        false
      end
    end

    def login(user:)
      self.class::ON_LOGIN.each do |on_login|
        send(on_login, user: user)
      end
      true
    end

    # LOGGING OUT

    def jump_out
      self.class::ON_LOGOUT.each { |on_logout| send(on_logout) }
      true
    end

    # HELPER METHODS

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = get_current_user
    end

    def logged_in?
      !!current_user
    end

    # CLASS METHODS

    module ClassMethods
      def jumpin_callback(callback, jumpin_method)
        jumpin_constant = callback.upcase
        unless self.constants.include?(jumpin_constant)
          const_set(jumpin_constant, [])
        end
        const_get(jumpin_constant) << jumpin_method
      end

      def jumpin_use(persistence:)
        persistence.each do |symbol|
          include(JumpIn::Authentication::Persistence
            .const_get(symbol.capitalize))
        end
      end
    end

    # PRIVATE

    private

    def get_current_user
      current_user = nil
      self.class.const_get(:GET_CURRENT_USER).each do |current_user_finder|
        current_user = send(current_user_finder)
        break if current_user
      end
      current_user
    end

    def detected_strategy(user:, auth_params:)
      if the_strategy = JumpIn::Strategies::Base::STRATEGIES
                        .detect { |strategy| strategy.detected?(auth_params) }
        the_strategy.new(user: user, auth_params: auth_params)
      else
        fail JumpIn::AuthenticationStrategyError
      end
    end
  end
end
