class BalanceController < ApplicationController
  # GET /balance or /balance.json
  def index
    if logged_in?
      reviews = policy_scope(Balance)
      render json: reviews
    else
      render json: []
    end
  end
end
