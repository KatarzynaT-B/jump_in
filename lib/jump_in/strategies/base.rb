require 'jump_in/strategies'

module JumpIn
  module Strategies
    class Base
      STRATEGIES = []

      def self.inherited(subclass)
        STRATEGIES << subclass
      end

      def initialize(user:, params:)
        @user = user
        @params = params
      end

      def authenticate_user
        true
      end

    end
  end
end
