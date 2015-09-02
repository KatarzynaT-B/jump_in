module JumpIn
  module Authentication
    module Session

      def set_session(user:)
        session[:jump_in_class] = user.class.to_s
        session[:jump_in_id]    = user.id
      end

      def delete_session
        session.delete :jump_in_class
        session.delete :jump_in_id
      end

    end
  end
end
