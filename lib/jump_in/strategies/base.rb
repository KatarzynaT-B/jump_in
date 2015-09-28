require 'jump_in/strategies'

module JumpIn
  module Strategies
    class Base
      STRATEGIES            = []
      DETECTABLE_ATTRIBUTES = {}

      def self.inherited(subclass)
        STRATEGIES << subclass
      end

      def self.has_unique_attributes(unique_attributes)
        unique_attributes.sort!
        if DETECTABLE_ATTRIBUTES.values.include?(unique_attributes)
          STRATEGIES.delete(self.name.constantize)
          raise JumpIn::AttributesNotUnique
        end
        DETECTABLE_ATTRIBUTES[self.name.constantize] = unique_attributes
      end

      def self.detected?(auth_params)
        auth_params.keys.sort == DETECTABLE_ATTRIBUTES[self.name.constantize]
      end

      def initialize(user:, auth_params:)
        @user = user
        @auth_params = auth_params
      end

      def authenticate_user
        true
      end
    end
  end
end
