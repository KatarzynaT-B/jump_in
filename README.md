# JumpIn

This gem is under improvement, please don't use it for production yet.

V.0.0.2 is not stable.

You're more than welcome to bring up issues!

JumpIn provides a set of methods that make building login & logout functionality really simple, with only few steps. It takes care of setting cookies or session. Moreover, it allows to choose authentication strategy which fits your application the best.

## Links:
- [Source Code](https://github.com/KatarzynaT-B/jump_in)


## Installation
```
gem 'jump_in'
```
Don't forget to run: `$ bundle install`.

In order to use JumpIn you need to include `JumpIn::Authentication` module in `application_controller.rb`:
```
class ApplicationController < ActionController::Base
  include JumpIn::Authentication
end
```

## Configuration
Default `JumpIn` configuration is:
- `permanent`: `false`,
- `expires`: `20.years`,
- `expiration_time`: `2.hours`.

You can modify it by running the generator:
```
$ rails generate jump_in:install_generator
```
which will create `config/initializers/jump_in.rb` for you. You can set custom values there (more explanation below).
/Whenever we mention 'configuration' further in the text, we asume you have `config/initializers/jump_in.rb` file in your app, generated by the `rails generate...` command./


## Authentication
This module provides complex `jump_in` method, two basic methods: `login` and `jump_out`, two helper methods: `current_user` and `logged_in?`, as well as extracted methods to be used according to your own preferences.

At the top of the controller you need to specify on-login(persistence) module(s) you want your controller to have acces to. Specify it with `jumpin_use` method.
It can be `jumpin_use persistence: [:session]` as well as `jumpin_use persistence: [:cookies]` or `jumpin_use persistence: [:session, :cookies]`.

If you create a custom on-login/on-logout/get-current-user functionality, you also add it here, `persistence: [:cookies, :your_module_name]`, e.g. `persistence: [:cookies, :mailing_module]`.
```
YourController < ActionController::Base
  ...
  jumpin_use persistence: [:session]
  ...
end
```

Methods:
```
jump_in(user:, **auth_params)
```
authenticates object and loggs it in (using `login` method). The authentication strategy is chosen based on the passed params.
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
login(user:)
```
depends on configuration set in `config/initializers/jump_in.rb`:
- it sets `session` for the given user (object) if `permanent` is set to `false` (default value),
- it sets `cookies.signed` if `permanent` is set to `true`. Suggested expiration time is 20 years (same as `cookies.permanent`). You can modify the expiration time in `config/initializers/jump_in.rb`.

If you're not using the comprehensive method `jump_in`, it is suggested to use `login` method as follows: `login(user: @student) unless logged_in?`
```
jump_out
```
logs user out (it clears session or cookies depending on the previous choice of login strategy). It takes no arguments.

* `current_user` - returns object that is currently logged in (`nil` otherwise),
* `logged_in?` - returns `true` if any object is logged in, `false` otherwise,
* `authenticate_by_strategy(user:, auth_params:)` - returns result of strategy's authentication method, returns `false` if strategy is not detected. All params needed for authentication must be passed as `auth_params` hash, e.g. `authenticate_by_strategy(user: @student, auth_params: { password: 'password'} )`,

### On-login Modules
Calling the `jumpin_use persistence: [...]` method you define which on-login modules your controller has access to.
The chosen module(s) should be consistent with `JumpIn configuration` (default configuration is consistent with `jumpin_use persistence: [:session]`).

You can use one or many modules at the same time. Their methods will be called in `jump_in`, `login`, `jump_out` methods. `current_user` will return the result of the first successful method (or `nil`).

#### Session
Contains the following methods:
- `set_user_session(user:)` - sets user's `class` & `id` in `session`;
- `remove_user_session` - deletes user's `class` & `id` from `session`;
- `current_user_from_session` - returns current user based on `session`, `nil` otherwise.

#### Cookies
Contains the following methods:
- `set_user_cookies(user:)` - sets user's `class` & `id` in `cookies.signed`;
- `remove_user_cookies` - deletes user's `class` & `id` from `cookies.signed`;
- `current_user_from_cookies` - returns current user based on `cookies.signed`, `nil` otherwise.

#### Custom
If you want to add a custom on-login/on-logout/find-current-user method, you should place it inside `JumpIn::Authentication::Persistence::YourModuleName` module and add proper callbacks in `self.included(klass)` method, e.g.:
```
module JumpIn
  module Authentication
    module Persistence
      module YourModuleName
        def self.included(klass)
          klass.jumpin_callback :on_login,         :your_on_login_method_name
          klass.jumpin_callback :on_logout,        :your_on_logout_method_name
          klass.jumpin_callback :get_current_user, :your_get_current_user_method_name

          APP_MAIN_CONTROLLER.class_eval do
            def your_get_current_user_method_name
              ...
            end
          end
        end

        def your_on_login_method_name
          ...
        end

        def your_on_logout_method_name
          ...
        end
      end
    end
  end
end
```
`on_login`, `on_logout` and `get_current_user` are used by the gem and are not to be changed.
Don't forget to specify the custom module in your app's controller (`jumpin_use persistence: [:you_module_name]`).

### Authentication Strategies
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
jump_in(user: @student, password: 'secretpassword')
```
What you need to pass is the object and password received in `params`.

If you only want to use the autentication method you should pass the password inside the hash: `auth_params`:
```
authenticate_by_strategy(user: @student, auth_params: { password: 'secretpassword' })
```


#### Authentication by OmniAuth
In order to log in with OmniAuth authentication you have to find (or create) the object by means of OmniAuth and then simply use `login` method as descirbed above. For example:
```
@student = Student.from_omniauth(request.env['omniauth.auth'])
if @student
  login(user: @student)
else
  ...
end
```

#### Custom strategies
`JumpIn` provides possibility to add your own custom authentication strategy. In order to do that you need to:

1. add custom `def authenticate(keyword_argument(s):)` method to the model to be authenticated.
It must use keyword arguments. The set of the arguments should be unique in comparison to sets of arguments of the other existing strategies (list below);
1. add new class iheriting by `JumpIn::Strategies::Base` and define:
  - `has_unique_attributes` - array of attributes used by the abovementioned `authenticate` method, it will be used to autmatically choose authentication strategy of your preference.
  - `authenticate_user` - that calls `@user.authenticate` with proper params.
```
class MyStrategy < JumpIn::Strategies::Base
  has_unique_attributes [:my_attribute, :another_attribute]

  def authenticate_user
    @user.authenticate(...) ? true : false
  end
end
```
List of the arguments taken by the existing default strategies:
- `ByPassword`: [:password].
