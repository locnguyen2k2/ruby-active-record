module SessionHelper
  def log_in(user)
    session[:user_id] = user.id
  end

  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def logged_in?
    !current_user.nil?
  end

  def forget(user)
    user.forgot
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def current_user
    if (user_id = session[:user_id]) && (user = User.eager_load(:role).find(user_id))
      @current_user ||= user
    elsif (user_id = cookies.encrypted[:user_id]) && (user = User.eager_load(:role).find(cookies.encrypted[:user_id])) && user.authenticated?(cookies[:remember_token])
      @current_user ||= user
    end
  end

  def logout
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
end
