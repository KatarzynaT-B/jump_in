require 'jump_in/strategies'

module JumpIn
  module Strategies
    class ByPassword < Base
      has_unique_attributes [:password]

      def authenticate_user
        @user.authenticate(@auth_params[:password]) ? true : false
      end
    end
  end
end
