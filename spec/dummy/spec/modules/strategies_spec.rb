require_relative '../spec_helper'

include JumpIn::Strategies

describe JumpIn::Strategies do

  before(:all) do
    class CustomStrategy < JumpIn::Strategies::Base
      has_unique_attributes [:custom_attr]

      def authenticate_user
        @user.authenticate(@auth_params[:custom_attr]) ? true : false
      end
    end

    class CustomUser
      def authenticate(to_verify)
        return true if to_verify == "authentication_pass"
        false
      end
    end
  end

  after(:all) do
    JumpIn::Strategies::Base::STRATEGIES.delete(CustomStrategy)
    JumpIn::Strategies::Base::DETECTABLE_ATTRIBUTES.delete(CustomStrategy)
  end

  context ".inherited" do
    it "STRATEGIES include default strategies" do
      expect(JumpIn::Strategies::Base::STRATEGIES).to include(JumpIn::Strategies::ByPassword)
    end

    it "STRATEGIES include custom strategies" do
      expect(JumpIn::Strategies::Base::STRATEGIES).to include(CustomStrategy)
    end
  end

  context "#authenticate_user" do
    it "calls custom authenticate method for custom strategy, returns true" do
      custom_user = CustomUser.new
      custom_strategy = CustomStrategy.new(
        user: custom_user,
        auth_params: { custom_attr: "authentication_pass" })
      expect(custom_strategy.authenticate_user).to eq(true)
    end

    it "calls custom authenticate method for custom strategy, returns false" do
      custom_user = CustomUser.new
      custom_strategy = CustomStrategy.new(
        user: custom_user,
        auth_params: { custom_attr: "wrong_pass" })
      expect(custom_strategy.authenticate_user).to eq(false)
    end
  end

  context ".has_unique_attribute" do
    it "adds strategy_unique_attribute to DETECTABLE_ATTRIBUTES" do
      expect(JumpIn::Strategies::Base::DETECTABLE_ATTRIBUTES.values).to include([:custom_attr])
    end

    it "raises error when strategy_unique_attribute is not unique, removes strategy from STRATEGIES" do
      expect {
        class AnotherCustomStrategy < JumpIn::Strategies::Base
          has_unique_attributes [:custom_attr]
        end
      }.to raise_error(JumpIn::AttributesNotUnique, 'Custom authentication strategy attribute is not unique.')
      expect(JumpIn::Strategies::Base::STRATEGIES).to_not include(AnotherCustomStrategy)
    end
  end
end
