require_relative '../spec_helper'

class SomeController < ActionController::Base
  include JumpIn
end

describe SomeController do

  context "JumpIn.configure not run" do
    it "has @conf with default values" do
      expect(JumpIn.conf.expires).to eq(20.years)
      expect(JumpIn.conf.expiration_time).to eq(2.hours)
    end
  end

  context "JumpIn.configure run" do
    it "has @conf available with proper expires" do
      run_config(expires: 5.years)
      expect(JumpIn.conf.expires).to eq(5.years)
    end

    it "has @conf available with proper expiration_time" do
      run_config(expiration_time: 5.hours)
      expect(JumpIn.conf.expiration_time).to eq(5.hours)
    end
  end

end
