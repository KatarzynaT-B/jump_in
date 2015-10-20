require_relative '../spec_helper'

### CUSTOM STRATEGY
module JumpIn::Custom
  def self.included(klass)
    klass.register_jumpin_callbacks(
      get_authenticated_user: [:user_from_custom])
  end

  def user_from_custom(user:, auth_params:)
  end
end
###

### BASIC APP STRUCTURE
class AppMainController < ActionController::Base
  include JumpIn
  jumpin_use :session, :cookies, :by_password, :custom
end

class AuthenticationController < AppMainController
end
###

### TWO GROUPS OF CONTROLLERS WITH DIFFERENT MODULES
class CommonController < ActionController::Base
  include JumpIn
end

class GroupOneController < CommonController
  jumpin_use :session, :by_password
end

class GroupTwoController < CommonController
  jumpin_use :cookies, :custom
end
###

describe AuthenticationController, type: :controller do
  let(:user_wsp) { FactoryGirl.create(:user_with_secure_password) }
  after(:all) { JumpIn.instance_variable_set('@configuration', nil) }

  context '.jumpin_use' do
    it 'adds proper methods only to the controller that includes' do
      expect(GroupOneController.new).to     respond_to(:current_user_from_session)
      expect(GroupOneController.new).to_not respond_to(:current_user_from_cookies)
      expect(GroupTwoController.new).to     respond_to(:current_user_from_cookies)
      expect(GroupTwoController.new).to_not respond_to(:current_user_from_session)
    end
  end

  context ".register_jumpin_callbacks" do
    it "adds default constants while including Session & Cookies" do
      expect(subject.class.constants).to include(:ON_LOGIN)
      expect(subject.class.constants).to include(:ON_LOGOUT)
      expect(subject.class.constants).to include(:GET_CURRENT_USER)
    end

    it "creates constant with method if constant didn't exist" do
      subject.class.jumpin_callback :a_callback, :method
      expect(subject.class.const_get(:A_CALLBACK)).to eq([:method])
    end

    it 'adds method if constant existed' do
      subject.class.const_set('B_CALLBACK', [:method_1])
      subject.class.jumpin_callback :b_callback, :method_2
      expect(subject.class.const_get(:B_CALLBACK)).to eq([:method_1, :method_2])
    end

    it 'adds default constant' do
      expect(subject.class.constants).to include(:GET_AUTHENTICATED_USER)
    end

    it 'adds authentication method from default strategy' do
      expect(subject.class.const_get(:GET_AUTHENTICATED_USER)).to include(:user_from_password)
    end

    it 'adds authentication method from custom strategy' do
      expect(subject.class.const_get(:GET_AUTHENTICATED_USER)).to include(:user_from_custom)
    end
  end

  context "#jump_in" do
    it "returns false if user logged_in" do
      allow_to_receive_logged_in_and_return(true)
      expect(subject.jump_in(user: user_wsp, password: user_wsp.password)).to eq(false)
    end

    it "returns false if user not logged_in and wrong login data provided" do
      allow_to_receive_logged_in_and_return(false)
      allow(subject).to receive(:authenticate_by_password).with(user: user_wsp, auth_params: {password: 'something'})
      expect(subject.jump_in(user: user_wsp, password: 'something')).to eq(false)
    end

    it "returns true when user not logged_in and authentication successful" do
      allow_to_receive_logged_in_and_return(false)
      allow(subject).to receive(:authenticate_by_password).with(user: user_wsp, auth_params: {password: user_wsp.password}).and_return(user_wsp)
      allow(subject).to receive(:login).with(user: user_wsp, by_cookies: false).and_return(true)
      expect(subject.jump_in(user: user_wsp, password: user_wsp.password)).to eq(true)
    end

    it 'works with alias method' do
      allow_to_receive_logged_in_and_return(true)
      expect(subject.authenticate_and_login(user: user_wsp, password: user_wsp.password)).to eq(false)
    end

    context 'custom strategy' do
      let(:user) { FactoryGirl.create(:user) }
      it 'calls custom strategy with passed param' do
        allow_to_receive_logged_in_and_return(false)
        expect(subject).to receive(:user_from_custom).with(user: user, auth_params: {is_fine: true})
        subject.jump_in(user: user, is_fine: true)
      end
    end
  end

  context "#login" do
    it "sets session when by_cookies not passed" do
      subject.login(user: user_wsp)
      expect_only_session_set_for(user_wsp)
    end

    it "sets session when by_cookies passed as false" do
      subject.login(user: user_wsp, by_cookies: false)
      expect_only_session_set_for(user_wsp)
    end

    it "sets cookies when by_cookies passed as true" do
      subject.login(user: user_wsp, by_cookies: true)
      expect_only_cookies_set_for(user_wsp)
    end

    context 'sets proper value for cookies[:expires]' do
      before(:each) do
        @cookies = OpenStruct.new(permanent: nil, signed: nil, jump_in_class: {}, jump_in_id: {})
        allow(subject).to receive(:cookies).and_return(@cookies)
        allow(@cookies).to receive(:permanent).and_return(@cookies)
        allow(@cookies).to receive(:signed).and_return(@cookies)
      end

      it "sets 20 years if @configuration.expires not set" do
        subject.login(user: user_wsp, by_cookies:true)
        expect(@cookies.signed[:jump_in_class][:expires]).to be_between(Time.now + 19.years, Time.now + 21.years)
        expect(@cookies.signed[:jump_in_id][:expires]).to be_between(Time.now + 19.years, Time.now + 21.years)
      end

      it "sets correct value if @configuration.expires set" do
        run_config(expires: 2.hours)
        subject.login(user: user_wsp, by_cookies: true)
        expect(@cookies.signed[:jump_in_class][:expires]).to eq(@cookies.signed[:jump_in_id][:expires])
        expect(@cookies.signed[:jump_in_class][:expires]).to be_between(Time.now + 1.hours, Time.now + 3.hours)
        expect(@cookies.signed[:jump_in_id][:expires]).to be_between(Time.now + 1.hours, Time.now + 3.hours)
      end
    end
  end

  context "#jump_out" do
    it "clears session when session set" do
      set_session(user_wsp)
      expect_session_eq(klass: user_wsp.class.to_s, id: user_wsp.id)
      subject.jump_out
      expect_session_eq(klass: nil, id: nil)
    end

    it "clears cookies when cookies set" do
      set_cookies(user_wsp, nil)
      expect_cookies_eq(klass: user_wsp.class.to_s, id: user_wsp.id)
      subject.jump_out
      expect_cookies_eq(klass: nil, id: nil)
    end

    it "returns true if logged out from session" do
      set_session(user_wsp)
      expect(subject.jump_out).to eq(true)
    end

    it "returns true if logged out from cookies" do
      set_cookies(user_wsp, nil)
      expect(subject.jump_out).to eq(true)
    end

    it "returns true if logged out from empty session & cookies" do
      expect(subject.jump_out).to eq(true)
    end
  end

  context "#current_user" do
    it "returns user based on session" do
      set_session(user_wsp)
      expect(subject.current_user).to eq(user_wsp)
    end

    it "returns user based on cookies" do
      set_cookies(user_wsp, nil)
      expect(subject.current_user).to eq(user_wsp)
    end

    it "returns nil when session and cookie empty" do
      expect(subject.current_user).to eq(nil)
    end
  end

  context "#logged_in?" do
    it "returns true if current user is set in session" do
      set_session(user_wsp)
      expect(subject.logged_in?).to eq(true)
    end

    it "returns true if current user is set in cookies" do
      set_cookies(user_wsp, nil)
      expect(subject.logged_in?).to eq(true)
    end
  end

  context "#helper_methods" do
    it "includes current_user and logged_in?" do
      expect(subject._helper_methods.include? :logged_in?).to eq(true)
      expect(subject._helper_methods.include? :current_user).to eq(true)
    end
  end
end
