class CashMovementsController < AuthenticatedController
  before_action { require_permission!(:can_manage_cash?) }
  before_action :set_cash_session

  def create
    @cash_movement = @cash_session.cash_movements.build(cash_movement_params)
    @cash_movement.restaurant = current_restaurant
    @cash_movement.created_by = current_user

    if @cash_movement.save
      redirect_to @cash_session, notice: "Movimiento registrado."
    else
      redirect_to @cash_session, alert: @cash_movement.errors.full_messages.to_sentence
    end
  end

  def destroy
    @cash_session.cash_movements.find(params[:id]).destroy
    redirect_to @cash_session, notice: "Movimiento eliminado."
  end

  private

  def set_cash_session
    @cash_session = current_restaurant.cash_sessions.find(params[:cash_session_id])
  end

  def cash_movement_params
    params.require(:cash_movement).permit(:kind, :amount, :description)
  end
end
