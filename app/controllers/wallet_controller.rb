class WalletController < ApplicationController
  before_action :set_wallet, only: [ :show ]
  def index
    if logged_in?
      reviews = policy_scope(Wallet)
      render json: reviews
    else
      render json: []
    end
  end

  def show
    authorize @wallet
    render json: @wallet, scope: { include: { balances: true } }
  end

  private
  def set_wallet
    id = params.require(:id)
    @wallet = Wallet.find_by(id: id)
    raise Errors::RecordNotFoundException if @wallet.nil?
  end
end
