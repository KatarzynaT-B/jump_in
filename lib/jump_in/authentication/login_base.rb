module JumpIn
  module Authentication
    module LoginBase
      def ensure_login_constants_in(klass)
        klass.const_set('ON_LOGIN', []) unless defined?(klass::ON_LOGIN)
        klass.const_set('ON_LOGOUT', []) unless defined?(klass::ON_LOGOUT)
        klass.const_set('GET_CURRENT_USER', []) unless defined?(klass::GET_CURRENT_USER)
      end
    end
  end
end
