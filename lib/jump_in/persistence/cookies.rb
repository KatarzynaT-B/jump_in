require 'jump_in/authentication'

module JumpIn
  module Persistence
    module Cookies
      def self.included(klass)
        klass.jumpin_callback :on_login,         :set_user_cookies
        klass.jumpin_callback :on_logout,        :remove_user_cookies
        klass.jumpin_callback :get_current_user, :current_user_from_cookies

        klass::APP_MAIN_CONTROLLER.class_eval do
          def current_user_from_cookies
            return nil unless cookies.signed[:jump_in_id] &&
                              cookies.signed[:jump_in_class]
            klass = cookies.signed[:jump_in_class].constantize
            klass.find_by(id: cookies.signed[:jump_in_id])
          end
        end
      end

      def set_user_cookies(user:)
        return nil unless JumpIn.conf.permanent
        expires = (JumpIn.conf.expires || 20.years).from_now
        cookies.signed[:jump_in_class] = { value: user.class.to_s,
                                           expires: expires }
        cookies.signed[:jump_in_id]    = { value: user.id, expires: expires }
      end

      def remove_user_cookies
        cookies.delete :jump_in_class
        cookies.delete :jump_in_id
      end
    end
  end
end
