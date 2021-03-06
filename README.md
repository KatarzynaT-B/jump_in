# JumpIn

This gem is under improvement, please don't use it for production yet.

V.0.0.2 is not stable.

You're more than welcome to bring up issues!

JumpIn provides a set of methods that make building login & logout functionality really simple with only few steps.
It takes care of setting cookies or session. Moreover, it allows to choose authentication strategy which fits your application the best.

## Links:
- [Source Code](https://github.com/KatarzynaT-B/jump_in)


## Installation
In your `Gemfile` add:
```
gem 'jump_in'
```
Don't forget to run: `$ bundle install`.


## Basic usage

In order to use the basic functionality of our gem, you only need two steps:
 1. include `JumpIn::Authentication` in the main controller that takes care of authentication in your app (e.g. `ApplicationController`),
 1. specify strategies you want to use in the main controller of the part of your application that is going to use them
 (app/API/whole application - this can be the `ApplicationController` as well).

That would quite often look as follows:
```
class ApplicationController < ActionController::Base
  include JumpIn::Authentication
  jumpin_use :session, :by_password
end
```
And that's it! Methods provided by the gem (especially `jump_in`, `current_user`, `jump_out`) are ready to be used.


## Detailed description

In order to use JumpIn you need to include `JumpIn::Authentication` in the main controller that takes care of authentication in your app,
e.g. in `application_controller.rb`:
```
class ApplicationController < ActionController::Base
  include JumpIn::Authentication
end
```


## Configuration
Default `JumpIn` configuration is:
- `expires`: `20.years` - it determines the expiration time of cookies, default is set to 20 years as in `cookies.permanent`.

You can modify it by running the generator:
```
$ rails generate jump_in:install
```
which will create `config/initializers/jump_in.rb` for you. You can set custom values there.

Whenever we mention 'configuration' further in the text, we asume you have `config/initializers/jump_in.rb` file in your app,
generated by the above mentioned command.


## Authentication
This module provides complex methods: `jump_in`, `login` and `jump_out`, two helper methods: `current_user` and `logged_in?`,
as well as extracted methods to be used according to your own preferences.

```
- jump_in(user:, by_cookies:false, **auth_params)
```
`jump_in` authenticates object and loggs it in (using `login` method). The authentication and login strategies are chosen
based on the passed params (details below).
The method returns `true` if user was successfully logged in, `false` otherwise. Suggested usage is:
```
# SessionController
def create
  @student = Student.find(...)
  if @student && jump_in(user: @student, password: params[:password])
    redirect_to ...
  else
    render :new
  end
end
```

```
- login(user:, by_cookies:false)
```
You only need `login` method if you're not using the comprehensive method `jump_in`.
`Login` method sets:
- `session` if `:session` strategy has been chosen and `user` is passed: `login(user: @student) unless logged_in?`,
- `cookies.signed` if `:cookies` strategy has been chosen and params passed are `user` and `by_cookies:true`,
Default expiration time of the cookies is set to 20 years (same as `cookies.permanent`). You can modify the expiration time in
`config/initializers/jump_in.rb`. `login(user: @student, by_cookies:true) unless logged_in?`

```
- jump_out
```
logs user out (it clears session or cookies depending on the previous choice of login strategy). It takes no arguments.

* `current_user` - returns object that is currently logged in (`nil` otherwise),
* `logged_in?` - returns `true` if any object is logged in, `false` otherwise,
* `get_authenticated_user(user:, auth_params:)` - returns result of strategy's authentication method: `user` on success, `nil` on failure. All params needed for authentication must be passed as `auth_params` hash, e.g. `get_authenticated_user(user: @student, auth_params: { password: 'password'} )`.


## Strategies

In order to use a strategies you need to specify them in the main controller of the part of your application
that is going to use them (app/API/whole application - it will quite often be the `ApplicationController`). You also specify you custom strategies here, e.g.:
 ```
class ApplicationController < ActionController::Base
  jumpin_use :session, :by_password
  # or jumpin_use :cookies, :by_password
  # or jumpin_user :session, :cookies, :by_password, :your_custom_strategy
end
```

#### Session
It is being used if `:session` is specified in `jumpin_use`.
It adds the following methods to your controller:
- `set_user_session(user:, by_cookies:)` - sets user's `class` & `id` in `session`;
- `remove_user_session` - deletes user's `class` & `id` from `session`;
- `current_user_from_session` - returns current user based on `session`, `nil` otherwise.

#### Cookies
It is being used if `:cookies` is specified in `jumpin_use`. For `jump_in` and `login` methods you also need to pass `by_cookies:true`.
It adds the following methods to your controller:
- `set_user_cookies(user:, by_cookies:)` - sets user's `class` & `id` in `cookies.signed`;
- `remove_user_cookies` - deletes user's `class` & `id` from `cookies.signed`;
- `current_user_from_cookies` - returns current user based on `cookies.signed`, `nil` otherwise.

#### ByPassword
JumpIn authentication by password uses `has_secure_password`'s authenticate method. Therefore you need to add column `password_digest` to your model's tabel and add: `has_secure_password` in the model to be authenticated. For example:
```
class YourClassName < ActiveRecord::Base
  has_secure_password
end
```
This strategy is being used when auth_params passed to `jump_in` or `get_authenticated_user` include `:password`, therefore you should use it this way:
```
jump_in(user: @student, password: 'secretpassword') # or jump_in(user: @student, by_cookies: true, password: 'secretpassword')
```
What you need to pass is the object and password received in `params`.

If you only want to use the autentication method you should pass the password inside the hash `auth_params`:
```
get_authenticated_user(user: @student, auth_params: { password: 'secretpassword' }) # by_cookies not relevant here
```

#### Authentication by OmniAuth
In order to log in with OmniAuth authentication you have to find (or create) the object by means of OmniAuth and then simply use `login` method as described above. For example:
```
@student = Student.from_omniauth(request.env['omniauth.auth'])
if @student
  login(user: @student) # or login(user: @student, by_cookies: true)
else
  ...
end
```

#### Custom
If you want to add a custom authentication/on-login/on-logout/find-current-user method, you should place it inside `JumpIn::Authentication::Strategies::YourModuleName` module and add proper callbacks in `self.included(klass)` method, e.g.:
```
module JumpIn::Authentication::Strategies::YourModuleName
  def self.included(klass)
    klass.register_jumpin_callbacks([
      on_login:               [:your_on_login_method_name], # you can add one or more methods here
      on_logout:              [:your_on_logout_method_name],
      get_current_user:       [:your_get_current_user_method_name]
      get_authenticated_user: [:your_get_authenticated_user_method_name])
  end

  def your_on_login_method_name
    ...
  end

  def your_on_logout_method_name
    ...
  end

  def your_get_current_user_method_name
    ...
  end

  def your_get_authenticated_user_method_name
    ...
  end
end
```
`on_login:`, `on_logout:`, `get_current_user:`,`get_authenticated_user:` are names used by the gem and are not to be changed. Pick the ones that you need.
Don't forget to specify the custom module in `jumpin_use :you_strategy_name`.

If you add an authentication method (that goes to `get_authenticated_user:` group) you need to add a custom `def authenticate()` method
to the model to be authenticated. It must take keyword arguments. The set of the arguments should be unique in comparison to sets
of arguments of the other existing strategies (list below).
```
class YourModel < ActiveRecord::Base
  def authenticate(keyword_arguments)
  end
end
```
Your authentication method should then compare passed params with the params your authentication strategy accepts
(in order to use the proper authentication strategy)
```
def your_get_authenticated_user_method_name(user:, auth_params:)
  return nil unless auth_params.keys == [you keyword_arguments] # e.g. [:param1, :param2, :param3]
  user.authenticate(...params using keyword arguments here...) ? user : nil
end
```
List of the arguments taken by the existing default strategies:
- `ByPassword`: [:password].

#### Combined strategies
Methods from chosen strategies are used alltogether. Gem's methods are iterating throught them.
- `on-login` methods - all methods from chosen strategies are being called
(these can be: `set_user_session`, `set_user_cookies`, your custom methods),
- `get-current-user` methods - the first one that finds the current user returns it's result (otherwise `nil` is returned)
(`current_user_from_session`, `current_user_from_cookies`, your custom methods),
- `on-logout` methods - all methods from chosen strategies are being performed
(`remove_user_session`, `remove_user_cookies`, your custom methods),
- `get-authenticated-user` - all the used strategies are being called (`user_from_password`, your custom methods),
but only the one that parameters match with the passed parameters performs the authentication.
However, it is possible to authenticate user by multiple strategies at the same time.
You just need to call `get_authenticated_user` once per each strategy (with proper params), for example:

```
YourController < ApplicationController
  jumpin_use persistence: [...], strategies: [:by_password, :by_token, :custom]

  def create
    @student = Student.find(name: params[:name])
    if !logged_in? &&
          get_authenticated_user(user: @student, auth_hash: { password: params[:password] }) &&
          get_authenticated_user(user: @student, auth_hash: { token: params[:token] }) &&
          get_authenticated_user(user: @student, auth_hash: { your_custom_data: params[:your_custom_data] })
      login(user: @student)
    else
      ...
    end
  end
end
```



