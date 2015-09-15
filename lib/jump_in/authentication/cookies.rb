require 'jump_in/authentication/login_base'

module JumpIn
  module Authentication
    class Cookies < LoginBase

      def perform_login
        if @params[:permanent] == true #condition from config
          expires = (@params[:expires] || 20.years).from_now
          cookies.signed[:jump_in_class] = { value: @user.class.to_s, expires: expires }
          cookies.signed[:jump_in_id]    = { value: @user.id, expires: expires }
        end
      end

      def cookies_set?
        cookies.signed[:jump_in_id] && cookies.signed[:jump_in_class]
      end

      def user_from_cookies
        klass = cookies.signed[:jump_in_class].constantize
        klass.find_by(id: cookies.signed[:jump_in_id])
      end

      def current_user
        cookies_set? ? user_from_cookies : false
      end

      def perform_logout
        cookies.delete :jump_in_class
        cookies.delete :jump_in_id
      end

    end
  end
end
