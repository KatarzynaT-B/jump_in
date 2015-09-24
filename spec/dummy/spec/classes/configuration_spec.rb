require_relative '../spec_helper'

class SomeController < ActionController::Base
  include JumpIn
end

describe SomeController do

  def run_config(permanent:nil, expires:nil, expiration_time:nil)
    JumpIn.configure do |defaults|
      defaults = {
      'permanent' => permanent,
      'expires' => expires,
      'expiration_time' => expiration_time
      }
    end
  end

  context "JumpIn.configure not run" do
    it "has @conf with default values" do
      expect(JumpIn.conf.permanent).to eq(false)
      expect(JumpIn.conf.expiration_time).to eq(2.hours)
    end
  end

  context "JumpIn.configure run" do
    it "has @conf with default permanent = false" do
      run_config()
      expect(JumpIn.conf.permanent).to eq(false)
    end

    it "has @conf available with proper params for cookies" do
      run_config(permanent: true, expires: 20.years)
      expect(JumpIn.conf.permanent).to eq(true)
      expect(JumpIn.conf.expires).to eq(20.years)
    end

    it "has @conf available with proper params for session" do
      run_config(permanent: false)
      expect(JumpIn.conf.permanent).to eq(false)
      expect(JumpIn.conf.expires).to eq(nil)
    end

    it "has @conf available with proper params for PasswordReset" do
      run_config(expiration_time: 2.hours)
      expect(JumpIn.conf.expiration_time).to eq(2.hours)
    end
  end
end
