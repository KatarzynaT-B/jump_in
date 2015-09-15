module JumpIn
  module Authentication
    module Session

      def set_session(user:)
        session[:jump_in_class] = user.class.to_s
        session[:jump_in_id]    = user.id
      end

      def session_set?
        session[:jump_in_id] && session[:jump_in_class]
      end

      def user_from_session
        klass = session[:jump_in_class].constantize
        klass.find_by(id: session[:jump_in_id])
      end

      def delete_session
        session.delete :jump_in_class
        session.delete :jump_in_id
      end

    end
  end
end
