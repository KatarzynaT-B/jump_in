require "jump_in/version"
require 'jump_in/authentication'
require 'jump_in/password_reset'
require 'jump_in/tokenator'

module JumpIn

  class Error < StandardError; end

  class InvalidTokenError < Error;
    def initialize
      message = "Invalid token passed."
      super(message)
    end
  end

end
