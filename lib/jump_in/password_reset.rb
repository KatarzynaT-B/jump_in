require 'jump_in/tokenator'

module JumpIn
  module PasswordReset
    include JumpIn::Tokenator

    # CREATING TOKEN
    def set_password_reset_for(user:, token: nil)
      if token_uniq_or_empty?(user: user, token: token)
        set_token(user: user, token: token)
      else
        false
      end
    end

    def set_token(user:, token: nil)
      token ||= generate_unique_token_for(user: user)
      user.update_attribute(:password_reset_token, token)
    end

    def generate_unique_token_for(user:)
      loop do
        token = generate_token
        break token if token_uniq?(user: user, token: token)
      end
    end

    def token_uniq_or_empty?(user:, token:)
      (token && token_uniq?(user: user, token: token)) || token.nil?
    end

    def token_uniq?(user:, token:)
      !user.class.where(password_reset_token: token).exists?
    end

    # RECEIVING TOKEN
    def password_reset_valid?(password_reset_token:)
      decode_time(password_reset_token) > Time.now - JumpIn.conf.expiration_time
    end

    def update_password_for(user:, password:, password_confirmation:,
                            password_reset_token:)
      return false unless token_correct?(user_token: user.password_reset_token,
                                         received_token: password_reset_token)
      user.update_attributes(password: password,
                             password_confirmation: password_confirmation,
                             password_reset_token: nil)
    end

    def token_correct?(user_token:, received_token:)
      user_token == received_token
    end
  end
end
