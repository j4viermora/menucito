class UsersController < AuthenticatedController
  before_action :require_manager
  before_action :set_user, only: [ :edit, :update, :destroy ]

  def index
    @users = current_restaurant.users.order(:name)
  end

  def new
    @user = current_restaurant.users.build(role: :waiter, active: true)
  end

  def create
    @user = current_restaurant.users.build(user_params)
    if @user.save
      redirect_to users_path, notice: "Usuario creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    attrs = user_params
    attrs = attrs.except(:password, :password_confirmation) if attrs[:password].blank?
    if @user.update(attrs)
      redirect_to users_path, notice: "Usuario actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to users_path, alert: "No puedes eliminar tu propio usuario."
      return
    end
    @user.destroy
    redirect_to users_path, notice: "Usuario eliminado."
  end

  private

  def require_manager
    return if current_user.can_manage_restaurant?
    redirect_to pos_path, alert: "No tienes permiso para gestionar usuarios."
  end

  def set_user
    @user = current_restaurant.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :role, :active, :password, :password_confirmation)
  end
end
