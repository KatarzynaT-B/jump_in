require 'jump_in/strategies'

module JumpIn
  module Strategies
    module ByOmniauth
      def self.included(klass)
        klass.jumpin_callback :get_authenticated_user, :user_from_omniauth
      end

      def user_from_omniauth(user:, auth_params:)
        proper_user = authenticate_by_omniauth(user: user, auth_params: auth_params)
        proper_user ? proper_user : nil
      end

      def authenticate_by_password(user:, auth_params:)
        found_user = nil
        user.class_list.each do |klass|
          found_user = klass.find_by(auth_params)
          break if found_user
        end
        found_user
      end

      class JumpInUsers < Struct.new(:class_list); end
    end
  end
end
