class UserController < ApplicationController
  protect_from_forgery

  before_action :set_user, only: [ :show, :update ]

  # GET /users or /users.json
  def index
    # authorize current_user
    if logged_in?
      reviews = policy_scope(User)
      users = reviews
      role_ids = users.pluck(:role_id)
      roles = Role.where("id IN (?)", role_ids)
      render json: users, scope: { roles: roles }
    else
      render json: []
    end
  end

  def update
    authorize @user
    @user.assign_attributes(user_params)
    @user.save
  end

  def profile
    authorize current_user
    render json: User.eager_load(:wallet).find(current_user.id), serializer: Users::UserWalletSerializer, scope: { include: { wallets: true } }
  end

  def show
    authorize @user
    render json: @user, scope: { include: { wallets: true } }
  end

  private
  def set_user
    user_id = params.require(:id)
    is_existed = User.eager_load(:wallets, :role).where(id: user_id)
    @user = is_existed.length > 0 ? is_existed[0] : nil
    raise Errors::RecordNotFoundException.new if @user.nil?
  end
  def user_params
    params.require(:user).permit(:first_name, :last_name)
  end
end
