require 'jump_in/authentication/login_base'

module JumpIn
  module Authentication
    module Session
      extend JumpIn::Authentication::LoginBase

      def self.included(klass)
        jumpin_callback klass, :on_login,         :set_user_session
        jumpin_callback klass, :on_logout,        :remove_user_session
        jumpin_callback klass, :get_current_user, :current_user_from_session
      end

      def set_user_session(user:, login_params:)
        unless login_params[:permanent] #condition from config
          session[:jump_in_class] = user.class.to_s
          session[:jump_in_id]    = user.id
        end
      end

      def remove_user_session
        session.delete :jump_in_class
        session.delete :jump_in_id
      end

      def current_user_from_session
        session_set? ? user_from_session : nil
      end

      private

      def session_set?
        session[:jump_in_id] && session[:jump_in_class]
      end

      def user_from_session
        klass = session[:jump_in_class].constantize
        klass.find_by(id: session[:jump_in_id])
      end
    end
  end
end
