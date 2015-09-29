require 'base64'

module JumpIn
  module Tokenator
    DELIMITER = '.'.freeze

    def generate_token
      Base64.urlsafe_encode64 [SecureRandom.hex(12), Time.now.xmlschema]
        .join(DELIMITER)
    end

    def decode_and_split_token(token)
      Base64.urlsafe_decode64(token).split(DELIMITER)
    rescue
      raise JumpIn::InvalidTokenError
    end

    def decode_time(token)
      token_time = decode_and_split_token(token)[1]
      Time.parse(token_time)
    rescue
      raise JumpIn::InvalidTokenError
    end
  end
end
