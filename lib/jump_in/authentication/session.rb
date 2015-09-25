require 'jump_in/authentication'

module JumpIn
  module Authentication
    module Persistence
      module Session
        def self.included(klass)
          klass.jumpin_callback :on_login,         :set_user_session
          klass.jumpin_callback :on_logout,        :remove_user_session
          klass.jumpin_callback :get_current_user, :current_user_from_session
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
          if session[:jump_in_id] && session[:jump_in_class]
            klass = session[:jump_in_class].constantize
            klass.find_by(id: session[:jump_in_id])
          else
            nil
          end
        end
      end
    end
  end
end
