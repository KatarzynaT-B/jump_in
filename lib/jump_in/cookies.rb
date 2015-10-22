require 'jump_in'

module JumpIn
  module Cookies
    def self.included(klass)
      klass.register_jumpin_callbacks(
        on_login:         [:set_user_cookies],
        on_logout:        [:remove_user_cookies],
        get_current_user: [:current_user_from_cookies] )
    end

    def set_user_cookies(user:, opts:)
      return nil unless opts[:by_cookies]
      expires = (JumpIn.conf.expires || 20.years).from_now
      cookies.signed[:jump_in_class] = { value: user.class.to_s,
                                         expires: expires }
      cookies.signed[:jump_in_id]    = { value: user.id, expires: expires }
    end

    def remove_user_cookies(user: nil)
      cookies.delete :jump_in_class
      cookies.delete :jump_in_id
    end

    def current_user_from_cookies
      return nil unless cookies.signed[:jump_in_id] &&
                        cookies.signed[:jump_in_class]
      klass = cookies.signed[:jump_in_class].constantize
      klass.find_by(id: cookies.signed[:jump_in_id])
    end
  end
end
