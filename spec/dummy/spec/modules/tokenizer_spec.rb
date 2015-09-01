require_relative '../spec_helper'

describe JumpIn::Tokenizer do
  let(:random) { 'e3d6ce35f9f6f7ea696cd180' }
  let(:time)   { Time.parse('2015-08-28T19:35:56+02:00') }
  let(:token)  { "ZTNkNmNlMzVmOWY2ZjdlYTY5NmNkMTgwLjIwMTUtMDgtMjhUMTk6MzU6NTYr\nMDI6MDA=\n" }

  context ".generate_token" do
    it 'generates token' do
      allow(SecureRandom).to receive(:hex).with(12).and_return(random)
      generated_token = nil
      travel_to time do
        generated_token = JumpIn::Tokenizer.generate_token
      end
      expect(generated_token).to eq(token)
    end
  end

  context ".decode_and_split_token" do
    it "decodes valid token" do
      expect(JumpIn::Tokenizer.decode_and_split_token(token)).to eq([random, time.xmlschema])
    end
    it "return gibberishi on invalid token" do
      return_value = ["\x8A{\xDA\x96'"].map {|v| v.force_encoding('ASCII-8BIT') }
      expect(JumpIn::Tokenizer.decode_and_split_token("invalid")).to eq(return_value)
    end
  end

  context ".decode_time" do
    it "decodes time for valid token" do
      expect(JumpIn::Tokenizer.decode_time(token)).to eq(time)
    end
    it "raises error for invalid token" do
      expect { JumpIn::Tokenizer.decode_time("invalid") }.to raise_error(TypeError, "no implicit conversion of nil into String")
    end
  end
end
