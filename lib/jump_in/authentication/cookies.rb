module JumpIn
  module Authentication
    module Cookies

      def set_cookies(user:, expires: nil)
        expires = (expires || 20.years).from_now
        cookies.signed[:jump_in_class] = { value: user.class.to_s, expires: expires }
        cookies.signed[:jump_in_id]    = { value: user.id, expires: expires }
      end

      def delete_cookies
        cookies.delete :jump_in_class
        cookies.delete :jump_in_id
      end

    end
  end
end
