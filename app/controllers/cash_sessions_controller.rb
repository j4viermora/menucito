class CashSessionsController < AuthenticatedController
  before_action :set_cash_session, only: [ :show, :close ]

  def index
    @cash_sessions = current_restaurant.cash_sessions.recent.limit(30)
  end

  def new
    if current_restaurant.current_cash_session
      redirect_to cash_session_path(current_restaurant.current_cash_session)
      return
    end
    @cash_session = current_restaurant.cash_sessions.build
  end

  def create
    if current_restaurant.current_cash_session
      redirect_to cash_session_path(current_restaurant.current_cash_session), alert: "Ya hay una caja abierta."
      return
    end

    @cash_session = current_restaurant.cash_sessions.build(
      opening_amount: params.dig(:cash_session, :opening_amount),
      opened_by: current_user,
      opened_at: Time.current,
      status: :open
    )

    if @cash_session.save
      redirect_to @cash_session, notice: "Caja abierta con #{@cash_session.opening_amount}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @cash_movements = @cash_session.cash_movements.recent
    @sales_summary = @cash_session.sales_summary
    @sold_orders = @cash_session.sold_orders
  end

  def close
    counted = params[:counted_amount].to_f
    @cash_session.close!(counted_amount: counted, closed_by: current_user, notes: params[:notes])
    redirect_to @cash_session, notice: "Caja cerrada. Diferencia: #{@cash_session.difference_amount}"
  end

  private

  def set_cash_session
    @cash_session = current_restaurant.cash_sessions.find(params[:id])
  end
end
