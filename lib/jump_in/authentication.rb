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
      def jumpin_use(persistence:, strategies:)
        modules_hash = { JumpIn::Persistence => persistence,
                         JumpIn::Strategies  => strategies }
        modules_hash.each do |top_module, modules_list|
          modules_list.each { |mod| include top_module.const_get(mod.to_s.camelcase) }
        end
      end

      def register_jumpin_callbacks(**callbacks_hash)
        callbacks_hash.each do |callback, jumpin_methods|
          jumpin_methods.each { |method| jumpin_callback(callback, method) }
        end
      end

      def jumpin_callback(callback, jumpin_method)
        jumpin_constant = callback.upcase
        const_set(jumpin_constant, []) unless const_defined?(jumpin_constant)
        const_get(jumpin_constant) << jumpin_method
      end
    end

    # PRIVATE
    private

    def get_current_user
      unless self.class.const_defined?(:GET_CURRENT_USER)
        fail JumpIn::ConstUndefined.new("'Undefined constant 'GET_CURRENT_USER' for #{self}")
      end
      detect_current_user
    end

    def detect_current_user
      user = nil
      self.class::GET_CURRENT_USER.detect do |tested_method|
        user = send(tested_method)
      end
      user
    end

    def get_authenticated_user(user:, auth_params:)
      unless self.class.const_defined?(:GET_AUTHENTICATED_USER)
        fail JumpIn::ConstUndefined.new("'Undefined constant 'GET_AUTHENTICATED_USER' for #{self}")
      end
      authenticated_user(user: user, auth_params: auth_params)
    end

    def authenticated_user(user:, auth_params:)
      auth_user = nil
      self.class::GET_AUTHENTICATED_USER.detect do |tested_method|
        auth_user = send(tested_method, user: user, auth_params: auth_params)
      end
      auth_user
    end
  end
end
