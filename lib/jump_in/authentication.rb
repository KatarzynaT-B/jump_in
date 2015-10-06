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
      if !logged_in? && (authenticated_user = get_authenticated_user(user: user,
                                                      auth_params: auth_params))
        login(user: authenticated_user)
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

      def jumpin_use(persistence:, strategies:)
        modules_hash = { JumpIn::Persistence => persistence,
                         JumpIn::Strategies  => strategies }
        modules_hash.keys.each do |top_module|
          modules_hash[top_module].each do |module_to_include|
            include top_module.const_get(module_to_include.to_s.camelcase)
          end
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

    def get_authenticated_user(user:, auth_params:)
      authenticated_user = nil
      self.class::GET_AUTHENTICATED_USER.each do |authenticate|
        authenticated_user = self.send(authenticate, user: user, auth_params: auth_params)
        break if authenticated_user
      end
      authenticated_user
    end
  end
end
