require "jump_in/version"
require 'jump_in/authentication'
require 'jump_in/authentication/session'
require 'jump_in/authentication/cookies'
require 'jump_in/strategies'
require 'jump_in/password_reset'
require 'jump_in/tokenator'

module JumpIn

  class Error < StandardError; end

  class InvalidTokenError < Error
    def initialize
      super("Invalid token passed.")
    end
  end

  class AuthenticationStrategyError < Error
    def initialize
      super("No authentication strategy detected.")
    end
  end

  class AttributeNotUnique < Error
    def initialize
      super("Custom authentication strategy attribute is not unique.")
    end
  end
end
