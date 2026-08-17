class SessionController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def new
  end

  def create
    args = login_params
    user = User.eager_load(:role).find_by(username: args[:username])
    if user && user.authenticate(args[:password])
      log_in user
      args[:remember_me] == "1" ? remember(user) : forget(user)
      render json: user
    else
      flash.now[:danger] = "Invalid email/password combination"
      render "new"
    end
  end

  def destroy
    logout if logged_in?
    redirect_to login_path
  end

  private
  def login_params
    params.require(:session).permit(:username, :password, :remember_me)
  end
end
