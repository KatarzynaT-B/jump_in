require_relative '../spec_helper'

class LoginBaseController < ActionController::Base
  include JumpIn::Authentication::LoginBase
end

describe LoginBaseController, type: :controller do
  it "creates constant if constant didn't exist" do
    subject.jumpin_callback subject.class, :on_login, :method
    expect(subject.class.const_get(:ON_LOGIN)).to eq([:method])
  end

  it 'adds method if constant existed' do
    subject.class.const_set('ON_LOGIN', [:method_1])

    subject.jumpin_callback subject.class, :on_login, :method_2
    expect(subject.class.const_get(:ON_LOGIN)).to eq([:method_1, :method_2])
  end

end
