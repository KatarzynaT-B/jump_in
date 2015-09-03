require 'jump_in/strategies'

module JumpIn
  module Strategies
    class ByPassword < Base
      def self.detected?(params)
        params.include? :password
      end

      def authenticate_user
        @user.authenticate(@params[:password]) ? true : false
      end
    end
  end
end
