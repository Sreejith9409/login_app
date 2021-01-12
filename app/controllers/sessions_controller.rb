class SessionsController < ApplicationController
  skip_before_action :authorized, only: [:new, :create]
  
  def new
    @user = User.new
  end
  
  def login
  end
  
  def create
    @user = User.where(login: params[:login])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect_to '/users'
    else
      redirect_to root_url
    end
  end
  def page_requires_login
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Logged out!"
  end
end
