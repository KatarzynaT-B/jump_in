require_relative '../spec_helper'

class TokenatorController < ActionController::Base
  include JumpIn::Tokenator
end

describe TokenatorController, type: :controller do
  let(:random) { 'e3d6ce35f9f6f7ea696cd180' }
  let(:time)   { Time.parse('2015-08-28T19:35:56+02:00') }
  let(:token)  { "ZTNkNmNlMzVmOWY2ZjdlYTY5NmNkMTgwLjIwMTUtMDgtMjhUMTk6MzU6NTYrMDI6MDA=" }

  context ".generate_token" do
    it 'generates token' do
      allow(SecureRandom).to receive(:hex).with(12).and_return(random)
      generated_token = nil
      travel_to time do
        generated_token = subject.generate_token
      end
      expect(generated_token).to eq(token)
    end
  end

  context ".decode_and_split_token" do
    it "decodes valid token" do
      expect(subject.decode_and_split_token(token)).to eq([random, time.xmlschema])
    end

    it "raises JumpIn error for invalid token" do
      expect { subject.decode_and_split_token("invalid") }.to raise_error(JumpIn::InvalidTokenError, 'Invalid token passed.')
    end
  end

  context ".decode_time" do
    it "decodes time for valid token" do
      expect(subject.decode_time(token)).to eq(time)
    end

    it "raises JumpIn error for invalid token" do
      expect { subject.decode_time("invalid") }.to raise_error(JumpIn::InvalidTokenError, 'Invalid token passed.')
    end

    it "raises JumpIn error for random passed as token (no delimiter => no time to parse)" do
      expect { subject.decode_time(random) }.to raise_error(JumpIn::InvalidTokenError, 'Invalid token passed.')
    end
  end
end
