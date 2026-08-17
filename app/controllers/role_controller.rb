class RoleController < ApplicationController
  def index
    if logged_in?
      reviews = policy_scope(Role)
      render json: reviews
    else
      render json: []
    end
  end
end
