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

  class AttributesNotUnique < Error
    def initialize
      super("Custom authentication strategy attribute is not unique.")
    end
  end

  def self.configure(&block)
    custom_config = yield
    @conf = Configuration.new(permanent:       custom_config["permanent"] || false,
                              expires:         custom_config["expires"],
                              expiration_time: custom_config["expiration_time"] || 2.hours)
  end

  def self.conf
    @conf || Configuration.new(permanent: false, expiration_time: 2.hours)
  end

  class Configuration
    attr_accessor :permanent, :expires, :expiration_time

    def initialize(permanent:nil, expires:nil, expiration_time:nil)
      @permanent       = permanent
      @expires         = expires
      @expiration_time = expiration_time
    end
  end

end
