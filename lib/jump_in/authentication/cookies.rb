require 'jump_in/authentication/login_base'

module JumpIn
  module Authentication
    module Cookies
      extend JumpIn::Authentication::LoginBase

      def self.included(klass)
        jumpin_callback klass, :on_login,         :set_user_cookies
        jumpin_callback klass, :on_logout,        :remove_user_cookies
        jumpin_callback klass, :get_current_user, :current_user_from_cookies
      end

      def set_user_cookies(user:, login_params:)
        if login_params[:permanent] == true #condition from config
          expires = (login_params[:expires] || 20.years).from_now
          cookies.signed[:jump_in_class] = { value: user.class.to_s, expires: expires }
          cookies.signed[:jump_in_id]    = { value: user.id, expires: expires }
        end
      end

      def remove_user_cookies
        cookies.delete :jump_in_class
        cookies.delete :jump_in_id
      end

      def current_user_from_cookies
        cookies_set? ? user_from_cookies : nil
      end

      private

      def cookies_set?
        cookies.signed[:jump_in_id] && cookies.signed[:jump_in_class]
      end

      def user_from_cookies
        klass = cookies.signed[:jump_in_class].constantize
        klass.find_by(id: cookies.signed[:jump_in_id])
      end
    end
  end
end
