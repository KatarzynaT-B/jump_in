require_relative '../spec_helper'

module JumpIn::LastLoggedOut
  def self.included(klass)
    klass.register_jumpin_callbacks(
      on_logout: [:keep_last_logout])
  end

  def keep_last_logout(user:, by_cookies:nil)
    user.update_attribute('last_logout', Time.now)
  end
end

class UserForLogin < ActiveRecord::Base
end

class ApplicationController < ActionController::Base
  include JumpIn
  jumpin_use :session, :by_password, :last_logged_out
end

class LastLoggedOutController < ApplicationController
end

describe LastLoggedOutController, type: :controller do
  before(:all) do
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
    ActiveRecord::Schema.define(:version => 1) do
      create_table :user_for_logins do |t|
        t.datetime :last_logout
      end
    end
  end

  after(:all) do
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
  end

  let(:user) { UserForLogin.new }

  context ".register_jumpin_callbacks" do
    it "adds on-logout constant" do
      expect(subject.class.constants).to include(:ON_LOGOUT)
    end

    it "on-login callback includes :keep_last_logout" do
      expect(subject.class.const_get(:ON_LOGOUT)).to eq([:remove_user_session, :keep_last_logout])
    end
  end

  context "#jump_out" do
    it 'calls LastLoggedIn strategy' do
      expect(subject).to receive(:keep_last_logout).with(user: user)
      subject.jump_out(user: user)
    end

    it 'saves last logout time' do
      expect(user.last_logout).to be_nil
      subject.jump_out(user: user)
      expect(user.last_logout).to_not be_nil
      expect(user.last_logout).to be_between(5.minutes.ago, Time.now).inclusive
    end
  end
end
