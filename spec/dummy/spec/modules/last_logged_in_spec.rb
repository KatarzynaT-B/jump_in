require_relative '../spec_helper'

module JumpIn::LastLoggedIn
  def self.included(klass)
    klass.register_jumpin_callbacks(
      on_login: [:keep_last_login])
  end

  def keep_last_login(user:, opts:)
    user.update_attribute('last_login', Time.now)
  end
end

class UserForLogin < ActiveRecord::Base
  has_secure_password
end

class ApplicationController1 < ActionController::Base
  include JumpIn
  jumpin_use :session, :by_password, :last_logged_in
end

class LastLoggedInController < ApplicationController1
end

describe LastLoggedInController, type: :controller do
  before(:all) do
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
    ActiveRecord::Schema.define(:version => 1) do
      create_table :user_for_logins do |t|
        t.text :password_digest
        t.datetime :last_login
      end
    end
  end

  after(:all) do
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
  end

  let(:user) { UserForLogin.new(password: 'secret') }

  context ".register_jumpin_callbacks" do
    it "adds on-login constant" do
      expect(subject.class.constants).to include(:ON_LOGIN)
    end

    it "on-login callback includes :keep_last_login" do
      expect(subject.class.const_get(:ON_LOGIN)).to eq([:set_user_session, :keep_last_login])
    end
  end

  context "#jump_in" do
    it 'calls LastLoggedIn strategy' do
      allow_to_receive_logged_in_and_return(false)
      expect(subject).to receive(:keep_last_login).with(user: user, opts: { by_cookies: false } )
      subject.jump_in(user: user, password: user.password)
    end
  end

  context "#login" do
    it 'saves last login time' do
      expect(user.last_login).to be_nil
      subject.login(user: user)
      expect(user.last_login).to_not be_nil
      expect(user.last_login).to be_between(5.minutes.ago, Time.now).inclusive
    end
  end
end
