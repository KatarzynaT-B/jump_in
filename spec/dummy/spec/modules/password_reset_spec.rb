require_relative '../spec_helper'

class PasswordResetController < ActionController::Base
  include JumpIn::PasswordReset
end

describe PasswordResetController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }

  context "#set_password_reset_for" do
    context "token not uniq_or_empty" do
      it "calls token_uniq_or_empty? with proper params" do
        token = 'token'
        expect(subject).to receive_token_uniq_or_empty_and_return(user, token, false)
        subject.set_password_reset_for(user:user, token:token)
      end

      it "returns false if token not uniq_or_empty" do
        token = 'token'
        allow(subject).to receive_token_uniq_or_empty_and_return(user, token, false)
        expect(subject.set_password_reset_for(user:user, token:token)).to eq(false)
      end
    end

    context "token uniq_or_empty" do
      it "calls set_token with given user & token if token uniq_or_empty" do
        token = 'token'
        expect(subject).to receive_token_uniq_or_empty_and_return(user, token, true)
        expect_set_token_and_return(user, token, true)
        subject.set_password_reset_for(user:user, token:token)
      end

      it "calls set_token with given user & token=nil if token uniq_or_empty & no token given" do
        token = nil
        expect(subject).to receive_token_uniq_or_empty_and_return(user, token, true)
        expect_set_token_and_return(user, token, true)
        subject.set_password_reset_for(user:user)
      end
    end
  end

  context "#set_token" do
    it "set's given token as user.token" do
      token = 'token'
      subject.set_token(user:user, token:token)
      expect(user.password_reset_token).to eq(token)
    end

    it "generates token for user if token=nil given" do
      expect(user.password_reset_token).to eq(nil)
      subject.set_token(user:user, token:nil)
      expect(user.password_reset_token).to_not eq(nil)
    end
  end

  context "#generate_unique_token_for" do
    it 'generates token' do
      token = subject.generate_unique_token_for(user:user)
      expect(token).to_not eq(nil)
    end

    it 'calls methods #generate_token & #token_uniq?' do
      token = 'token'
      expect(subject).to receive(:generate_token).and_return(token)
      expect(subject).to receive(:token_uniq?).with(user:user, token:token).and_return(true)
      subject.generate_unique_token_for(user:user)
    end
  end

  context "#generate_token" do
    it 'generates token' do
      token = subject.generate_token
      expect(token).to_not eq(nil)
    end
  end

  context "#token_uniq_or_empty?" do
    it 'returns true if token is nil' do
      expect(subject.token_uniq_or_empty?(user:user, token:nil)).to eq(true)
    end

    it 'returns true if token given & unique' do
      token = 'token'
      allow(subject).to receive(:token_uniq?).with(user:user, token:token).and_return(true)
      expect(subject.token_uniq_or_empty?(user:user, token:token)).to eq(true)
    end

    it 'returns false if token give & not unique' do
      token = 'token'
      allow(subject).to receive(:token_uniq?).with(user:user, token:token).and_return(false)
      expect(subject.token_uniq_or_empty?(user:user, token:token)).to eq(false)
    end
  end

  context "#token_uniq?" do
    it 'returns true if token unique for user.class' do
      token = subject.generate_token
      expect(subject.token_uniq?(user:user, token:token)).to eq(true)
    end

    it 'returns false if token not unique for user.class' do
      token = subject.generate_token
      user.update_attribute('password_reset_token', token)
      expect(subject.token_uniq?(user:user, token:token)).to eq(false)
    end
  end

  context "#password_reset_valid?" do
    it "returns true for token valid with default expiration time(2.hours)" do
      token = JumpIn::Tokenator.generate_token
      expect(subject.password_reset_valid?(password_reset_token: token)).to eq(true)
    end

    it "returns false for token too old with default expiration time(2.hours)" do
      token = ''
      travel_to(3.hours.ago) do
        token = JumpIn::Tokenator.generate_token
      end
      expect(subject.password_reset_valid?(password_reset_token: token)).to eq(false)
    end

    it "returns true for token valid with custom expiration time(2.days)" do
      token = ''
      travel_to(1.day.ago) do
        token = JumpIn::Tokenator.generate_token
      end
      expect(subject.password_reset_valid?(password_reset_token: token, expiration_time: 2.days)).to eq(true)
    end

    it "returns false for token too old with custom expiration time(2.days)" do
      token = ''
      travel_to(3.days.ago) do
        token = JumpIn::Tokenator.generate_token
      end
      expect(subject.password_reset_valid?(password_reset_token: token, expiration_time: 2.days)).to eq(false)
    end

  end

  context "#update_password_for" do
    let(:new_password) { 'new_secret_password'}
    let!(:old_password_digest) { user.password_digest }

    it "updates password if token belongs to user and is not too old" do
      user.update_attribute(:password_reset_token, JumpIn::Tokenator.generate_token)
      token = user.password_reset_token
      allow_to_receive_token_correct_and_return(user, token, true)

      expect(
        subject.update_password_for(user: user, password: new_password, password_confirmation: new_password, password_reset_token: token)
      ).to eq(true)
      expect(user.password_digest).to_not eq(old_password_digest)
    end

    it "updates password if token belongs to user and is old" do
      travel_to(3.days.ago) do
        user.update_attribute(:password_reset_token, JumpIn::Tokenator.generate_token)
      end
      token = user.password_reset_token
      allow_to_receive_token_correct_and_return(user, token, true)

      expect(
        subject.update_password_for(user: user, password: new_password, password_confirmation: new_password, password_reset_token: token)
      ).to eq(true)
      expect(user.password_digest).to_not eq(old_password_digest)
    end

    it "does not update password and returns false if token does not belong to user" do
      user.update_attribute(:password_reset_token, JumpIn::Tokenator.generate_token)
      token = JumpIn::Tokenator.generate_token
      allow_to_receive_token_correct_and_return(user, token, false)

      expect(
        subject.update_password_for(user: user, password: new_password, password_confirmation: new_password, password_reset_token: token)
      ).to eq(false)
      expect(user.password_digest).to eq(old_password_digest)
    end

    it "does not update password and returns false if new password invalid" do
      user.update_attribute(:password_reset_token, JumpIn::Tokenator.generate_token)
      token = user.password_reset_token
      allow_to_receive_token_correct_and_return(user, token, true)

      expect(
        subject.update_password_for(user: user, password: new_password, password_confirmation: 'password', password_reset_token: token)
      ).to eq(false)
      user.reload
      expect(user.password_digest).to eq(old_password_digest)
    end
  end

  context "#token_correct?" do
    it "returns true if given token eq user.token" do
      user.update_attribute(:password_reset_token, JumpIn::Tokenator.generate_token)
      token = user.password_reset_token
      expect(subject.token_correct?(user_token:user.password_reset_token, received_token:token)).to eq(true)
    end

    it "returns false if given token doesn't eq user.token" do
      user.update_attribute(:password_reset_token, JumpIn::Tokenator.generate_token)
      token = JumpIn::Tokenator.generate_token
      expect(subject.token_correct?(user_token:user.password_reset_token, received_token:token)).to eq(false)
    end
  end
end
