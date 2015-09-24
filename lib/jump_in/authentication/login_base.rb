module JumpIn
  module Authentication
    module LoginBase
      LOGINS = []

      def self.included(login_module)
        JumpIn::Authentication::LoginBase::LOGINS << login_module
      end

      def self.perform_login(user: nil, contr: nil, login_params: nil)
      end

      def self.current_user(contr: nil)
        nil
      end

      def self.perform_logout(contr: nil)
      end

    end
  end
end
