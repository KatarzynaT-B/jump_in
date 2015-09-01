class PasswordResetsController < ApplicationController

  before_filter :authorize_by_token, :only => [:edit, :update]

  def create
    @user = User.find_by(email: params[:email].downcase)
    if set_password_reset_for(user: @user)
      redirect_to login_path
    else
      render :new
    end
  end

  def update
    user = User.where(password_reset_token: params[:token]).first
    if user && update_password_for(user: user,
                                   password: params[:password],
                                   password_confirmation: params[:password_confirmation],
                                   password_reset_token: params[:token])
      redirect_to login_path
    else
      render :edit
    end
  end

  private
  def authorize_by_token
    unless password_reset_valid?(password_reset_token: params[:token])
      redirect_to new_password_resets_path
    end
  end
end
