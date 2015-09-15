require "jump_in/version"
require 'jump_in/authentication'
require 'jump_in/authentication/session'
require 'jump_in/authentication/cookies'
require 'jump_in/strategies'
require 'jump_in/password_reset'
require 'jump_in/tokenator'
# require 'jump_in/generators/jump_in/install_generator'      ?????
# require 'jump_in/generators/templates/jump_in_initializer'  ?????

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

  class ConfigurationError < Error
    def initialize
      message = 'JumpInConfiguration not available, run initializer jump_in.rb.'
      super(message)
    end
  end

  def self.configure(&block)
    defaults = yield
    @conf = Configuration.new(permanent:       defaults["permanent"] || false,
                              expires:         defaults["expires"],
                              expiration_time: defaults["expiration_time"])
  end

  def self.conf
    @conf || (raise JumpIn::ConfigurationError)
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
