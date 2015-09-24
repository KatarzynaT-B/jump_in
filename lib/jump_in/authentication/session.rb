require 'jump_in/authentication/login_base'


module JumpIn
  module Authentication
    module Session
      include JumpIn::Authentication::LoginBase

      def self.perform_login(user:, contr:, login_params:)
        unless login_params[:permanent] #condition from config
          contr.session[:jump_in_class] = user.class.to_s
          contr.session[:jump_in_id]    = user.id
        end
      end

      def self.session_set?(contr:)
        contr.session[:jump_in_id] && contr.session[:jump_in_class]
      end

      def self.user_from_session(contr:)
        klass = contr.session[:jump_in_class].constantize
        klass.find_by(id: contr.session[:jump_in_id])
      end

      def self.current_user(contr:)
        session_set?(contr: contr) ? user_from_session(contr: contr) : nil
      end

      def self.perform_logout(contr:)
        contr.session.delete :jump_in_class
        contr.session.delete :jump_in_id
      end

    end
  end
end
