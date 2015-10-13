require 'jump_in/strategies'
require 'jump_in/persistence'

module JumpIn
  module Authentication
    def self.included(base)
      base.extend(ClassMethods)
      base.send :helper_method, :current_user, :logged_in? if
        base.respond_to? :helper_method
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
      self.class::ON_LOGIN.each {|on_login| send(on_login, user: user) }
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
        const_set(jumpin_constant, []) unless const_defined?(jumpin_constant)
        const_get(jumpin_constant) << jumpin_method
      end

      def jumpin_use(persistence:, strategies:)
        modules_hash = { JumpIn::Persistence => persistence,
                         JumpIn::Strategies  => strategies }
        modules_hash.each do |top_module, modules_list|
          modules_list.cycle(1) { |mod| include top_module.const_get(mod.to_s.camelcase) }
        end
      end
    end

    # PRIVATE
    private

    def get_current_user
      (method = detect_current_user_method) ? send(method) : nil
    end

    def get_authenticated_user(user:, auth_params:)
      method = detect_authenticate_method(user: user, auth_params: auth_params)
      method ? send(method, user: user, auth_params: auth_params) : nil
    end

    def detect_current_user_method
      if const_defined?(GET_CURRENT_USER)
        self.class::GET_CURRENT_USER.detect { |tested_method| send(tested_method) }
      end
    end

    def detect_authenticate_method(user:, auth_params:)
      if const_defined?(GET_AUTHENTICATED_USER)
        self.class::GET_AUTHENTICATED_USER.detect do |tested_method|
          send(tested_method, user: user, auth_params: auth_params)
        end
      end
    end
  end
end
