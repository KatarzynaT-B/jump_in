JumpIn.configure do |config|
  # AUTHENTICATION

  # for `permanent` set to
  # - true - login method sets cookies,
  # - false - login method sets session.

  config.permanent = true

  # `expires` is used by login method only when `permanent` is set to true
  # It defines expiration time for cookies.
  # Default value is set to 20 years - as in cookies.permanent.
  # You can uncomment the line below and change it.

  # config.expires = 20.years

  # PASSWORD RESET

  # `expiration_time` is used by PasswordReset#password_reset_valid?
  # to verify whether password_reset_token is still valid.
  # Default value is set to 2 hours.
  # You can uncomment the line below and change it.

  # config.expiration_time = 2.hours
end
