class SessionsController < ApplicationController

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && jump_in(user: user, permanent: true, password: params[:session][:password])
      redirect_to user_path(user)
    else
      render :new
    end
  end

  def destroy
    jump_out
    redirect_to login_path
  end
end
