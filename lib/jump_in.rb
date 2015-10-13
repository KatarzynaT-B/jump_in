require 'jump_in/version'
require 'jump_in/authentication'
require 'jump_in/password_reset'

# JumpIn top-level module
module JumpIn
  class Error < StandardError
    def initialize(message = nil)
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

  class ConstUndefined < Error
  end

  def self.configure(&block)
    yield(conf)
  end

  def self.conf
    @configuration ||= Configuration.new
  end

  class Configuration
    attr_accessor :expires, :expiration_time

    def initialize
      @expires         = 20.years
      @expiration_time = 2.hours
    end
  end
end
