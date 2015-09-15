module JumpIn
  module Authentication
    class LoginBase
      LOGINS = []

      def self.inherited(subclass)
        LOGINS << subclass
      end

      def initialize(user: nil, login_params: nil) #login params to be removed after config merge
        @user = user
        @params = login_params
      end

      def perform_login(user:)
      end

      def current_user
        false
      end

      def perform_logout(user:)
      end

    end
  end
end
