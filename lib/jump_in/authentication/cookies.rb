require 'jump_in/authentication/login_base'

module JumpIn
  module Authentication
    module Cookies
      include JumpIn::Authentication::LoginBase

      def self.perform_login(user:, contr:, login_params:)
        if login_params[:permanent] == true #condition from config
          expires = (login_params[:expires] || 20.years).from_now
          contr.cookies.signed[:jump_in_class] = { value: user.class.to_s, expires: expires }
          contr.cookies.signed[:jump_in_id]    = { value: user.id, expires: expires }
        end
      end

      def self.cookies_set?(contr:)
        contr.cookies.signed[:jump_in_id] && contr.cookies.signed[:jump_in_class]
      end

      def self.user_from_cookies
        klass = cookies.signed[:jump_in_class].constantize
        klass.find_by(id: cookies.signed[:jump_in_id])
      end

      def self.current_user(contr:)
        cookies_set?(contr: contr) ? user_from_cookies(contr: contr) : nil
      end

      def self.perform_logout(contr:)
        contr.cookies.delete :jump_in_class
        contr.cookies.delete :jump_in_id
      end

    end
  end
end
