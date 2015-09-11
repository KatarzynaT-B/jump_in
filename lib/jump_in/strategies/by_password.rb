require 'jump_in/strategies'

module JumpIn
  module Strategies
    class ByPassword < Base
      def self.detected?(auth_params)
        auth_params.include? :password
      end

      def authenticate_user
        @user.authenticate(@auth_params[:password]) ? true : false
      end
    end
  end
end
