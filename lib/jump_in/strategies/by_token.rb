require 'jump_in/strategies'

module JumpIn
  module Strategies
    module ByToken
      def self.included(klass)
        klass.jumpin_callback :get_authenticated_user, :user_from_token
      end

      def user_from_token(user:, auth_params:)
        return nil unless auth_params.keys == [:token]
        user.jumpin_token == auth_params[:token] ? user : nil
      end
    end
  end
end
