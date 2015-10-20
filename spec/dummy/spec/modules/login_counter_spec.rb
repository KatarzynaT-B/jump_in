require_relative '../spec_helper'

module JumpIn::LoginCounter
  def self.included(klass)
    klass.register_jumpin_callbacks(
      on_login: [:count_logins])
  end

  def count_logins(user:, by_cookies:nil)
    user.update_attribute('logins_count', user.logins_count + 1)
  end
end

class UserForLogin < ActiveRecord::Base
  has_secure_password
end

class ApplicationController < ActionController::Base
  include JumpIn
  jumpin_use :session, :by_password, :login_counter
end

class LoginCounterController < ApplicationController
end

describe LoginCounterController, type: :controller do
  before(:all) do
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
    ActiveRecord::Schema.define(:version => 1) do
      create_table :user_for_logins do |t|
        t.text :password_digest
        t.integer :logins_count, default: 0
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

    it "on-login callback includes :count_logins" do
      expect(subject.class.const_get(:ON_LOGIN)).to eq([:set_user_session, :count_logins])
    end
  end

  context "#jump_in" do
    it 'calls LastLoggedIn strategy' do
      allow_to_receive_logged_in_and_return(false)
      expect(subject).to receive(:count_logins).with(user: user, by_cookies: false)
      subject.jump_in(user: user, password: user.password)
    end
  end

  context "#login" do
    it 'increases logins_count' do
      expect(user.logins_count).to eq(0)
      subject.login(user: user)
      expect(user.logins_count).to eq(1)
    end
  end
end
