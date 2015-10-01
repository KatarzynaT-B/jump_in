require 'jump_in/version'
require 'jump_in/authentication'
require 'jump_in/authentication/session'
require 'jump_in/authentication/cookies'
require 'jump_in/strategies'
require 'jump_in/password_reset'
require 'jump_in/tokenator'
# JumpIn top-level module
module JumpIn
  class Error < StandardError
    def initialize
      super(message)
    end
  end

  class InvalidTokenError < Error
    def message
      'Invalid token passed.'
    end
  end

  class AuthenticationStrategyError < Error
    def message
      'No authentication strategy detected.'
    end
  end

  class AttributesNotUnique < Error
    def message
      'Custom authentication strategy attribute is not unique.'
    end
  end

  def self.configure(&block)
    yield(conf)
  end

  def self.conf
    @configuration ||= Configuration.new
  end

  class Configuration
    attr_accessor :permanent, :expires, :expiration_time

    def initialize
      @permanent       = false
      @expires         = 20.years
      @expiration_time = 2.hours
    end
  end
end
