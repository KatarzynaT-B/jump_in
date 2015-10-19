
def run_config(expires: 20.years, expiration_time: 2.hours)
  JumpIn.configure do |config|
    config.expires = expires
    config.expiration_time = expiration_time
  end
end

# module Authentication

def set_session(object)
  session[:jump_in_class] = object.class.to_s
  session[:jump_in_id] = object.id
end

def set_cookies(object, expires)
  cookies.permanent.signed[:jump_in_class] = { :value => object.class.to_s, :expires => expires }
  cookies.permanent.signed[:jump_in_id] = { :value => object.id, :expires => expires }
end

def expect_session_eq(klass:, id:)
  expect(session[:jump_in_class]).to eq(klass)
  expect(session[:jump_in_id]).to eq(id)
end

def expect_cookies_eq(klass:, id:)
  expect(cookies.signed[:jump_in_class]).to eq(klass)
  expect(cookies.signed[:jump_in_id]).to eq(id)
end

def expect_only_session_set_for(user)
  expect_session_eq(klass: user.class.to_s, id: user.id)
  expect_cookies_eq(klass: nil, id: nil)
end

def expect_only_cookies_set_for(user)
  expect_cookies_eq(klass: user.class.to_s, id: user.id)
  expect_session_eq(klass: nil, id: nil)
end

def allow_to_receive_logged_in_and_return(boolean)
  allow(subject).to receive(:logged_in?).and_return(boolean)
end
