require 'jump_in/authentication'

module JumpIn
  module Persistence
    module Session

      def self.included(klass)
        klass.register_jumpin_callbacks(
          on_login:         [:set_user_session],
          on_logout:        [:remove_user_session],
          get_current_user: [:current_user_from_session] )
      end

      def set_user_session(user:)
        return nil if JumpIn.conf.permanent
        session[:jump_in_class] = user.class.to_s
        session[:jump_in_id]    = user.id
      end

      def remove_user_session
        session.delete :jump_in_class
        session.delete :jump_in_id
      end

      def current_user_from_session
        return nil unless session[:jump_in_id] && session[:jump_in_class]
        klass = session[:jump_in_class].constantize
        klass.find_by(id: session[:jump_in_id])
      end
    end
  end
end
