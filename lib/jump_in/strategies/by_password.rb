require 'jump_in/strategies'

module JumpIn
  module Strategies
    module ByPassword
      def self.included(klass)
        klass.jumpin_callback :get_authenticated_user, :user_from_password
      end

      def user_from_password(user:, auth_params:)
        return nil unless auth_params.keys == [:password]
        authenticate_by_password(user: user, auth_params: auth_params) ? user : nil
      end

      def authenticate_by_password(user:, auth_params:)
        user.authenticate(auth_params[:password])
      end
    end
  end
end
