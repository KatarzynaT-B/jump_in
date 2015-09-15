require 'jump_in/authentication/login_base'


module JumpIn
  module Authentication
    class Session < LoginBase

      def perform_login
        if @params[:permanent] == false #condition from config
          session[:jump_in_class] = @user.class.to_s
          session[:jump_in_id]    = @user.id
        end
      end

      def session_set?
        session[:jump_in_id] && session[:jump_in_class]
      end

      def user_from_session
        klass = session[:jump_in_class].constantize
        klass.find_by(id: session[:jump_in_id])
      end

      def current_user
        session_set? ? user_from_session : false
      end

      def perform_logout
        session.delete :jump_in_class
        session.delete :jump_in_id
      end

    end
  end
end
