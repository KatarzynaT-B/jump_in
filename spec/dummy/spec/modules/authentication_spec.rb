require_relative '../spec_helper'

class AuthenticationController < ActionController::Base
  include LetMeIn::Authentication
end

describe AuthenticationController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }

  context "#let_me_in" do
    it "returns false if user logged_in" do
      allow_to_receive_logged_in_and_return(true)
      expect(subject.let_me_in(user: user, password: user.password)).to eq(false)
    end

    it "calls detect_strategy with proper params" do
      allow_to_receive_logged_in_and_return(false)
      expect(subject).to receive(:detected_strategy).with(user: user, params: { password: user.password }).
        exactly(1).times.and_return(LetMeIn::Authentication::ByPassword.new(user: user, params: { password: user.password }))
      subject.let_me_in(user: user, password: user.password)
    end

    it "returns false if user not logged_in and wrong login data provided" do
      allow_to_receive_logged_in_and_return(false)
      expect(subject.let_me_in(user: user, password:'something')).to eq(false)
    end

    context 'when user not logged_in and authentication successful' do
      it "returns true" do
        allow_to_receive_logged_in_and_return(false)
        expect(subject.let_me_in(user: user, password: user.password)).to eq(true)
      end

      it "calls 'login' with permanent=false for permanent false by default" do
        allow_to_receive_logged_in_and_return(false)
        expect(subject).to receive(:login).with(user:user, permanent:false, expires:nil).exactly(1).times.and_return(true)
        subject.let_me_in(user: user, password: user.password)
      end

      it "calls 'login' with permanent=false for permanent passed as false" do
        allow_to_receive_logged_in_and_return(false)
        expect(subject).to receive(:login).with(user:user, permanent:false, expires:nil).exactly(1).times.and_return(true)
        subject.let_me_in(user: user, password: user.password, permanent: false)
      end

      it "calls 'login' with permanent=true for permanent passed as true" do
        allow_to_receive_logged_in_and_return(false)
        expect(subject).to receive(:login).with(user:user, permanent:true, expires:nil).exactly(1).times.and_return(true)
        subject.let_me_in(user: user, password: user.password, permanent: true)
      end
    end
  end

  context "#login" do
    it "sets session when permanent not passed (default)" do
      subject.login(user: user)
      expect_only_session_set_for(user)
    end

    it "sets session when permanent passed as false" do
      subject.login(user: user, permanent: false)
      expect_only_session_set_for(user)
    end

    it "sets cookies when permanent passed as true" do
      subject.login(user: user, permanent: true)
      expect_only_cookies_set_for(user)
    end

    context 'sets proper value for cookies[:expires]' do
      before(:each) do
        @cookies = OpenStruct.new(permanent: nil, signed: nil, let_me_in_class: {}, let_me_in_id: {})
        allow(subject).to receive(:cookies).and_return(@cookies)
        allow(@cookies).to receive(:permanent).and_return(@cookies)
        allow(@cookies).to receive(:signed).and_return(@cookies)
      end

      it "sets 20 years if param not passed" do
        subject.login(user: user, permanent: true)
        expect(@cookies.signed[:let_me_in_class][:expires]).to be_between(Time.now + 19.years, Time.now + 21.years)
        expect(@cookies.signed[:let_me_in_id][:expires]).to be_between(Time.now + 19.years, Time.now + 21.years)
      end

      it "sets correct value if param passed" do
        subject.login(user: user, permanent: true, expires: 2.hours)
        expect(@cookies.signed[:let_me_in_class][:expires]).to eq(@cookies.signed[:let_me_in_id][:expires])
        expect(@cookies.signed[:let_me_in_class][:expires]).to be_between(Time.now + 1.hours, Time.now + 3.hours)
        expect(@cookies.signed[:let_me_in_id][:expires]).to be_between(Time.now + 1.hours, Time.now + 3.hours)
      end
    end
  end

  context "#let_me_out" do
    it "clears session when session set" do
      set_session(user)
      expect_session_eq(klass: user.class.to_s, id: user.id)
      subject.let_me_out
      expect_session_eq(klass: nil, id: nil)
    end

    it "clears cookies when cookies set" do
      set_cookies(user, nil)
      expect_cookies_eq(klass: user.class.to_s, id: user.id)
      subject.let_me_out
      expect_cookies_eq(klass: nil, id: nil)
    end

    it "returns true if logged out from session" do
      set_session(user)
      expect(subject.let_me_out).to eq(true)
    end

    it "returns true if logged out from cookies" do
      set_cookies(user, nil)
      expect(subject.let_me_out).to eq(true)
    end

    it "returns true if logged out from empty session & cookies" do
      expect(subject.let_me_out).to eq(true)
    end
  end

  context "#current_user" do
    it "returns user based on session" do
      set_session(user)
      expect(subject.current_user).to eq(user)
    end

    it "returns user based on cookies" do
      set_cookies(user, nil)
      expect(subject.current_user).to eq(user)
    end

    it "returns nil when session and cookie empty" do
      expect(subject.current_user).to eq(nil)
    end
  end

  context "#logged_in?" do
    it "returns true if current user is set in session" do
      set_session(user)
      expect(subject.logged_in?).to eq(true)
    end

    it "returns true if current user is set in cookies" do
      set_cookies(user, nil)
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
