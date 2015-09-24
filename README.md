# JumpIn

JumpIn provides a set of methods that make building login & logout functionality really simple, with only few steps. It takes care of setting cookies or session and has it's own tokenator. Moreover, it allows to choose authentication strategy which fits your application the best.

## Links:
- [Source Code](https://github.com/KatarzynaT-B/jump_in)


## Installation
```
gem 'jump_in'
```
Don't forget to run: `$ bundle install`.

At this point (or later), if you want to modify default `JumpIn` configuration (as you'll read further: `permanent`, `expires`, `expiration_time`), you need to run the generator. It will create `config/initializers/jump_in.rb` for you:
```
$ rails generate jump_in:install
```
If the default settings of the above mentioned file is not what you need, feel free to modify it. Remember to insert `,` after each hash element except of the last!

/Whenever we mention `config/initializers/jump_in.rb` further in the text, we asume you have run the `rails generate` command./


In order to use JumpIn you need to include modules of your choice in `application_controller.rb` or in a controller responsible for a particular functionality. For example in case of logging in with password and using password reset functionality you'll need:
```
class ApplicationController < ActionController::Base
  include JumpIn::Authentication
  include JumpIn::PasswordReset
end
```
Here is a complete list of modules that JumpIn provides:
* `JumpIn::Authentication`
* `JumpIn::PasswordReset`
* `JumpIn::Tokenator` (included by default when `JumpIn::PasswordReset` is included)


## Authentication
```
include JumpIn::Authentication
```
This module provides complex `jump_in` method, two basic methods: `login` and `jump_out`, as well as two helper methods: `current_user` and `logged_in?` and extracted methods to be used according to your own preferences.
```
jump_in(user:, **auth_params)
```
authenticates object and loggs it in (using `login` method). The authentication strategy depends on the passed auth_params (detaild description below). Suggested usage of this method is (inside `SessionsController`):
```
def create
  @student = Student.find(...)
  if @student && jump_in(user: @student, password: auth_params[:password])
    redirect_to ...
  else
    render :new
  end
end
```
```
login(user:)
```
depends on settings located in `config/initializers/jump_in.rb`:
- it sets `session` for the given user (object) if `permanent` is set to `false` (`false` is default `JumpIn` config),
- it sets `cookies.signed` if `permanent` is set to `true`. Suggested expiration time is 20 years (same as `cookies.permanent`). You can modify the expiration time in `config/initializers/jump_in.rb`.

If you're not using the comprehensive method `jump_in`, it is suggested to use `login` method as follows: `login(user: @student) unless logged_in?`
```
jump_out
```
logs out user (it clears session or cookies depending on the previous choice of login strategy). It takes no arguments.

* `current_user` - returns object that is currently logged in (`nil` otherwise),
* `logged_in?` - returns `true` if any object is logged in (by means of the above mentioned login method). Otherwise it returns `false`,

* `authenticate_by_strategy(user:, auth_params:)` - returns result of strategy-authentication, returns `false` if strategy is not detected. All params needed for authentication need to be passed as hash, e.g. `authenticate_by_strategy(user: @student, auth_params: { password: 'password'} )`,
* `set_cookies(user:)` - sets `cookies.signed`. Expiration time depends on `config/initializers/jump_in.rb`, default value is set to 20 years as in `cookies.permanent`,
* `set_session(user:)` - sets session,
* `delete_cookies` - clears cookies set by `set_cookies`,
* `delete_session` - clears session set by `set_session`.


#### Authentication Strategies
At the moment JumpIn provides one strategy: `ByPassword`. Strategy `ByOmniAuth` is in progress, strategy `ByToken` is in our minds, other strategies are more then welcome to come from your suggestions!


#### Authentication by password
JumpIn authentication by password uses `has_secure_password`'s authenticate method. Therefore you need to add column `password_digest` to your model's tabel and add: `has_secure_password` in the model to be authenticated. For example:
```
class YourClassName < ActiveRecord::Base
  has_secure_password
end
```
This strategy is being used when auth_params passed to `jump_in` or `authenticate_by_strategy` include `:password`, therefore you should use it this way:
```
jump_in(user: @student, permanent: true, expires: 30.days, password: auth_params[:password])
```
What you need to pass is the object to be authenticated (and logged in), password received in auth_params and optionally: `permanent` and `expires` parameters (as explained in `login` method description).

As for the second method you should use it this way, passing the password in a hash (`auth_params`):
```
authenticate_by_strategy(user: @student, auth_params: { password: 'secretpassword' })
```



#### Authentication by OmniAuth
In order to log in with OmniAuth authentication you have to find (or create) the object by means of OmniAuth and then simply use `login` method as descirbed above. For example:
```
@student = Student.from_omniauth(request.env['omniauth.auth'])
if @student
  login(user: @student, permanent: true)
else
  ...
end
```

#### Custom strategies
`JumpIn` provides possibility to add your own custom authentication strategy. In order to do that you need to:

1. add custom `def authenticate(...)` method to the model to be authenticated.
It must use keyword arguments. Set of the arguments should be unique in comparison to other existing strategies (list below);
1. add new class iheriting by `JumpIn::Strategies::Base` and define:
  - `has_unique_attributes` - array of attributes used by the abovementioned `authenticate` method, it will be used to autmatically choose authentication strategy of your preference.
  - `authenticate_user` - that calls `@user.authenticate` with proper params.
```
class MyStrategy < JumpIn::Strategies::Base
  has_unique_attributes :my_key_attribute

  def authenticate_user
    @user.authenticate(...) ? true : false
  end
end
```
List of the arguments taken by the existing default strategies:
- `ByPassword`: [:password].

## Password Reset
```
include JumpIn::PasswordReset
```
This functionality requires two columns in your model's table: `password_digest` and `jumpin_reset_token`. With these attributes your application is ready to use the following methods:
* `set_password_reset_for`
* `set_token`
* `generate_unique_token_for`
* `token_uniq?`
* `password_reset_valid?`
* `update_password_for`
* `token_correct?`

Of course you won't have to use all of them by yourself. Everything depends on your preferences.
There are two main and comprehensive methods that cover most of the work: `set_password_reset_for` and `update_password_for`. The rest are just methods extracted in order to let you build your own, custom functionality.
```
set_password_reset_for(user:, token: nil)
```
takes one required argument: an object that the password reset is performed for, passed as a named parameter `user` (for example: `set_password_reset_for(user: @student)`) and sets a unique token as the object's attribute `jumpin_reset_token`. The token is generated by `JumpIn::Tokenator` described below.

If the optional parameter is passed (`token`, e.g. `set_password_reset_for(user: @user, token: your_token)`) the method checks uniqueness of the given token and sets it as the object's `jumpin_reset_token`. It returns `false` if the given token is not unique.

The subsidiary methods are:
* `set_token(user:, token: nil)` - updates object's attribute `jumpin_reset_token` to the given token (although it does not check it's uniqueness) or token generated by Tokenator (if no token passed),
* `generate_unique_token_for(user:)` - generates unique token by means of `JumpIn::Tokenator`, the token is unique in scope of the passed object's class,
* `token_uniq?(user:, token:)` - checks uniqueness of the given token in scope of the passed object's class.

```
password_reset_valid?(password_reset_token:)
```
checkes wheather the given token is still valid (has not expired). Returns `true` or `false`. Default expiration time is 2 hours. You can change this value in `config/initializers/jump_in.rb`. This method is suitable for token generated with `JumpIn::Tokenator`.
```
update_password_for(user:, password:, password_confirmation:, password_reset_token:)
```
verifies correctness of the given token (it's identity with the object's `jumpin_reset_token`) and updates object's `password_digest`. Returns `false` if the token is incorrect.

Suggested usage is: (unless expiration time for tokens is not what you need)
```
if password_reset_valid?(password_reset_token: token)
  update_password_for(user: user, password: password, password_confirmation: password_confirmation, password_reset_token: token)
else
  ...
end
```
And the subsidiary method:
* `token_correct?(user_token:, received_token:)` - verifies identity if the object's token and the received token, e.g. `token_correct?(user_token: @student.jumpin_reset_token, received_token: params[:token]`.


## Tokenator
```
include JumpIn::Tokenator
```
As mentioned above, this module is included by default with the password reset functionality. Thus in most cases there is no need to include it explicitly. However, in case your application doesn't use the password reset functionality but it needs the tokenator somewhere else, you're free to include this module seperately.
`JumpIn::Tokenator` provides two methods that you might need: `JumpIn::Tokenator.generate_token` and `JumpIn::Tokenator.decode_time`.
* `JumpIn::Tokenator.generate_token`
 generates safe token by means of `Base64` & `SecureRandom`. It contains encrypted token generation time.
* `JumpIn::Tokenator.decode_time(token)`
 decodes the token generation time from the token. It takes single parameter (that is the `token`) and returns a `datetime` object. It can be used to verify wheather the token is still valid (has not expired).
